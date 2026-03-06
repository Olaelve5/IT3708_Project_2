using Random
using Statistics 

include(joinpath(@__DIR__, "load_data.jl"))

Random.seed!(123)

include(joinpath(@__DIR__, "Individual.jl"))
include(joinpath(@__DIR__, "plot.jl"))
include(joinpath(@__DIR__, "crossover.jl")) 
include(joinpath(@__DIR__, "mutation.jl"))   
include(joinpath(@__DIR__, "parent_selection.jl"))
include(joinpath(@__DIR__, "best_splits.jl"))
include(joinpath(@__DIR__, "crowding.jl"))
include(joinpath(@__DIR__, "entropy.jl"))

# =========== Parameters ============
const ISLAND_POP_SIZE = 600  
const NUM_ISLANDS = 4
const MAX_GENERATIONS = 10000
const CROSSOVER_RATE = 0.9
const ROUTE_CROSSOVER_SHARE = 0.6
const BASE_MUTATION_RATE = 0.25
const MIGRATION_INTERVAL = 100   
const NUM_MIGRANTS = 2           

# =========== GA Loop ===========
function run_instance(instance_path::String, max_generations::Int)
    println("\n--- Starting GA ---")
    
    # Load Data
    if !isfile(instance_path)
        error("File not found: $instance_path")
    end
    println("Loading instance: $instance_path")
    instance = load_instance(instance_path)
    num_patients = length(instance.patients)
    println("Loaded $(instance.instance_name): $num_patients patients, $(instance.nbr_nurses) nurses.")

    # Initialize Islands
    println("Initializing $NUM_ISLANDS islands with population $ISLAND_POP_SIZE each...")
    islands = [initialize_population(ISLAND_POP_SIZE, num_patients) for _ in 1:NUM_ISLANDS]

    # Initial fitness evaluation
    for island in islands
        for ind in island
            ind.fitness, ind.splits = prins_algo(ind.genotype, instance)
        end
        sort!(island, by = ind -> ind.fitness)
    end

    # Track the best solution ever found across all islands
    global_best_ever = deepcopy(islands[1][1])

    # Track fitness and entropy
    fitness_history = Float64[]
    entropy_history = Float64[]

    # Evolution loop
    for gen in 1:max_generations
        
        # Evolution phase for each island
        for island_idx in 1:NUM_ISLANDS
            current_island = islands[island_idx]
            random_indices = randperm(ISLAND_POP_SIZE)
            mutation_rate = BASE_MUTATION_RATE
            
            for i in 1:2:ISLAND_POP_SIZE
                p1_idx = random_indices[i]
                p2_idx = random_indices[i+1]
                p1 = current_island[p1_idx]
                p2 = current_island[p2_idx]

            # Crossover
            if rand() < CROSSOVER_RATE
                c1, c2 = mixed_crossover(p1, p2, instance; route_share=ROUTE_CROSSOVER_SHARE)
            else
                c1 = deepcopy(p1)
                c2 = deepcopy(p2)
            end

            # Mutate
            hybrid_mutation!(c1, mutation_rate)
            hybrid_mutation!(c2, mutation_rate)

                # Calculate fitness if necessary
                if c1.fitness == Inf || c1.fitness == 0.0
                    c1.fitness, c1.splits = prins_algo(c1.genotype, instance)
                end
                if c2.fitness == Inf || c2.fitness == 0.0
                    c2.fitness, c2.splits = prins_algo(c2.genotype, instance)
                end

                # Crowding
                survivor1, survivor2 = deterministic_crowding(p1, p2, c1, c2)
                current_island[p1_idx] = survivor1
                current_island[p2_idx] = survivor2
            end

            # Sort
            sort!(current_island, by = ind -> ind.fitness)
            
            # Save global best individual
            if current_island[1].fitness < global_best_ever.fitness
                global_best_ever = deepcopy(current_island[1])
            end
            
            # Check for low entropy and inject new random individuals if needed
            entropy = calculate_population_entropy(current_island)
            if entropy < 5.0 
                num_elites_to_save = div(ISLAND_POP_SIZE, 10)
                
                # Replace the bottom 90%
                for i in (num_elites_to_save + 1):ISLAND_POP_SIZE
                    new_genotype = randperm(num_patients)
                    current_island[i] = Individual(new_genotype)
                    current_island[i].fitness, current_island[i].splits = prins_algo(current_island[i].genotype, instance)
                end
                
                sort!(current_island, by = ind -> ind.fitness)
            end
        end

        # Migration
        if gen % MIGRATION_INTERVAL == 0
            # Island 1 sends to Island 2, Island 2 sends to Island 3...
            migrants = [Individual[] for _ in 1:NUM_ISLANDS]
            
            # Find best individuals
            for i in 1:NUM_ISLANDS
                for j in 1:NUM_MIGRANTS
                    push!(migrants[i], deepcopy(islands[i][j]))
                end
            end
            
            # Replace the worst ones with the imigrants
            for i in 1:NUM_ISLANDS
                sender_idx = (i == 1) ? NUM_ISLANDS : i - 1

                for j in 1:NUM_MIGRANTS
                    islands[i][ISLAND_POP_SIZE - j + 1] = deepcopy(migrants[sender_idx][j])
                end
    
                sort!(islands[i], by = ind -> ind.fitness)
            end
        end

        # Logging (global metrics)
        if gen % 10 == 0 || gen == 1
            all_individuals = vcat(islands...)
            global_avg = mean(ind.fitness for ind in all_individuals)
            global_entropy = calculate_population_entropy(all_individuals)
            percentage = 100 * (global_best_ever.fitness - instance.benchmark) / instance.benchmark

            push!(fitness_history, global_best_ever.fitness)
            push!(entropy_history, global_entropy)
            
            println("Gen $gen | Global Best: $(round(global_best_ever.fitness, digits=2)) | Global Avg: $(round(global_avg, digits=2)) | % from BM: $(round(percentage, digits=2))% | Global Entropy: $(round(global_entropy, digits=2))%")
        end
    end

    best_percentage::Float64 = round(100 * (global_best_ever.fitness - instance.benchmark) / instance.benchmark, digits=2)

    println("\n--- GA Loop Finished ---")
    println("Final Best Fitness: $(round(global_best_ever.fitness, digits=2))")
    println("Percentage from benchmark: $best_percentage% \n")

    return (
        instance_name=instance.instance_name, 
        best_fitness=global_best_ever.fitness, 
        benchmark=instance.benchmark, 
        percentage=best_percentage, 
        best_individual=global_best_ever, 
        instance=instance, 
        fitness_history=fitness_history, 
        entropy_history=entropy_history
        )
end

function main()
    results = []

    for i in 1:3
        if i == 1
            gens = 10000
        else
            gens = 25000
        end

        path = "data/test_instance_$i.json"
        result = run_instance(path, gens)
        push!(results, result)
    end

    # Print summary table
    println("\n" * "="^80)
    println("SUMMARY OF ALL INSTANCES")
    println("="^80)
    println(rpad("Instance", 20) * rpad("Best Fitness", 15) * rpad("Benchmark", 15) * rpad("% from BM", 15))
    println("-"^80)
    for r in results
        println(
            rpad(r.instance_name, 20) *
            rpad(round(r.best_fitness, digits=2), 15) *
            rpad(round(r.benchmark, digits=2), 15) *
            rpad(string(round(r.percentage, digits=2), "%"), 15)
        )
    end
    println("-"^80)
    avg_pct = mean(r.percentage for r in results)
    println("Average % from benchmark: $(round(avg_pct, digits=2))%")
    println("="^80)

    # Plots
    # for r in results
    #     println("\nPlotting best solution for $(r.instance_name)...")
    #     plot_routes(r.instance, r.best_individual, ISLAND_POP_SIZE, MAX_GENERATIONS, r.percentage)
    #     plot_convergence(r.fitness_history, r.entropy_history, r.instance_name)
    # end
end

# Run the script
main()
