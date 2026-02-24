using Random
using Statistics 

include(joinpath(@__DIR__, "load_data.jl"))
include(joinpath(@__DIR__, "Individual.jl"))
include(joinpath(@__DIR__, "greedy_split.jl"))
include(joinpath(@__DIR__, "plot.jl"))
include(joinpath(@__DIR__, "Fitness.jl"))
include(joinpath(@__DIR__, "crossover.jl"))  # To be implemented
include(joinpath(@__DIR__, "mutation.jl"))   # To be implemented
include(joinpath(@__DIR__, "parent_selection.jl"))


# =========== Parameters ============
const INSTANCE_PATH = "data/train_0.json"
const POP_SIZE = 10000
const MAX_GENERATIONS = 1000
const NURSE_PENALTY_FACTOR::Float64 = 0.0


# =========== GA Loop ===========
function main()
    println("\n--- Starting GA ---")
    
    # Load Data
    if !isfile(INSTANCE_PATH)
        error("File not found: $INSTANCE_PATH")
    end
    println("Loading instance: $INSTANCE_PATH")
    instance = load_instance(INSTANCE_PATH)
    num_patients = length(instance.patients)
    println("Loaded $(instance.instance_name): $num_patients patients, $(instance.nbr_nurses) nurses.")

    # Initialize Population
    println("Initializing population...")
    population = initialize_population(POP_SIZE, num_patients)

    for ind in population
        ind.splits = greedy_split(ind.genotype, instance)
    end
    
    # Fill in fitness of initial population
    population_fitness!(population, instance.travel_times, NURSE_PENALTY_FACTOR)

    best_ever = population[1] # Init
    # Evolution loop
    for gen in 1:MAX_GENERATIONS
        offspring = Individual[]
        
        while length(offspring) < POP_SIZE
            p1, p2 = select_parents(population, 10)
            child = route_crossover(p1, p2, instance)
            #reversal_mutation!(child, 1/length(child.genotype))
            swap_mutation!(child, 1/length(child.genotype))
            push!(offspring, child)
            
            
        end

        # Fill in splits
        population_splits!(offspring, instance)
        
        # Fill in fitness of offspring population
        population_fitness!(offspring, instance.travel_times, NURSE_PENALTY_FACTOR)
        # TODO: Survivor Selection (e.g., elitism, generational replacement)

        population = offspring # Placeholder for survivor selection
        sort!(population, by = ind -> ind.fitness)
        # 5. Logging
        current_best_idx = argmax(ind.fitness for ind in population)
        current_best = population[current_best_idx]
        avg_fitness = mean(ind.fitness for ind in population)
        
        println("Gen $gen | Best: $(round(current_best.fitness, digits=2)) | Avg: $(round(avg_fitness, digits=2))")

        if current_best.fitness < best_ever.fitness
            best_ever = current_best
        end
    
    end

    println("\n--- GA Loop Finished ---")
    println("Final Best Fitness: $(round(best_ever.fitness, digits=2))")
    println("Genotype: $(best_ever.genotype)")

    # Plot the best solution
    println("Plotting best solution...")

    # Placeholder to test plot
    println("Route splits (indices for each split): $(best_ever.splits)")

    plot_routes(instance, best_ever)
end

# Run the script
main()