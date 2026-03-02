using Random
using Statistics 

include(joinpath(@__DIR__, "load_data.jl"))
include(joinpath(@__DIR__, "Individual.jl"))
include(joinpath(@__DIR__, "greedy_split.jl"))
include(joinpath(@__DIR__, "plot.jl"))
include(joinpath(@__DIR__, "Fitness.jl"))
include(joinpath(@__DIR__, "crossover.jl")) 
include(joinpath(@__DIR__, "mutation.jl"))   
include(joinpath(@__DIR__, "parent_selection.jl"))
include(joinpath(@__DIR__, "best_splits.jl"))
include(joinpath(@__DIR__, "crowding.jl"))
include(joinpath(@__DIR__, "elitism.jl"))
include(joinpath(@__DIR__, "entropy.jl"))


# =========== Parameters ============
const POP_SIZE = 2000
const MAX_GENERATIONS = 5000


# =========== GA Loop ===========
function run_instance(instance_path::String)
    println("\n--- Starting GA ---")
    
    # Load Data
    if !isfile(instance_path)
        error("File not found: $instance_path")
    end
    println("Loading instance: $instance_path")
    instance = load_instance(instance_path)
    num_patients = length(instance.patients)
    println("Loaded $(instance.instance_name): $num_patients patients, $(instance.nbr_nurses) nurses.")

    # Initialize Population
    println("Initializing population...")
    population = initialize_population(POP_SIZE, num_patients)

    for ind in population
        ind.fitness, ind.splits = prins_algo(ind.genotype, instance)
    end

    best_ever = population[1]

    # Evolution loop
    for gen in 1:MAX_GENERATIONS
        
        # Create random pairs for crossover
        random_indices = randperm(POP_SIZE)
        
        for i in 1:2:POP_SIZE
            p1_idx = random_indices[i]
            p2_idx = random_indices[i+1]
            p1 = population[p1_idx]
            p2 = population[p2_idx]

            # Crossover
            if rand() < 0.8
                c1, c2 = route_crossover(p1, p2, instance)
            else
                c1 = deepcopy(p1)
                c2 = deepcopy(p2)
            end

            # Mutate
            hybrid_mutation!(c1, 0.2)
            hybrid_mutation!(c2, 0.2)

            # Calculate fitness if necessary
            if c1.fitness == Inf || c1.fitness == 0.0
                c1.fitness, c1.splits = prins_algo(c1.genotype, instance)
            end
            if c2.fitness == Inf || c2.fitness == 0.0
                c2.fitness, c2.splits = prins_algo(c2.genotype, instance)
            end

            # Crowding
            survivor1, survivor2 = deterministic_crowding(p1, p2, c1, c2)
            population[p1_idx] = survivor1
            population[p2_idx] = survivor2
        end

        # Sort the population so the best is at index 1
        sort!(population, by = ind -> ind.fitness)

        # Always keep the best one from the previous generation (elitism)
        if population[1].fitness > best_ever.fitness
            population[end] = deepcopy(best_ever)
            sort!(population, by = ind -> ind.fitness)
        end

        # Logging
        current_best = population[1]
        avg_fitness = mean(ind.fitness for ind in population)
        percentage = 100 * (current_best.fitness - instance.benchmark) / instance.benchmark
        entropy = calculate_population_entropy(population)
        
        println("Gen $gen | Best: $(round(current_best.fitness, digits=2)) | Avg: $(round(avg_fitness, digits=2)) | % from BM: $(round(percentage, digits=2))% | Entropy: $(round(entropy, digits=2))%")

        if current_best.fitness < best_ever.fitness
            best_ever = deepcopy(current_best)
        end
    end

    percentage::Float64 = 100 * (best_ever.fitness - instance.benchmark) / instance.benchmark

    println("\n--- GA Loop Finished ---")
    println("Final Best Fitness: $(round(best_ever.fitness, digits=2))")
    println("Percentage from benchmark: $(round(percentage, digits=2))%\n")

    return (instance_name=instance.instance_name, best_fitness=best_ever.fitness, benchmark=instance.benchmark, percentage=percentage, best_individual=best_ever, instance=instance)
end

function main()
    results = []

    for i in 8:8
        path = "data/train_$i.json"
        result = run_instance(path)
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

    # Plot the best solution for each instance
    for r in results
        println("\nSaving best solution for $(r.instance_name)...")
        plot_routes(r.instance, r.best_individual, POP_SIZE, MAX_GENERATIONS, r.percentage)
    end
end

# Run the script
main()