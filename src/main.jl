using Random
using Statistics 

include(joinpath(@__DIR__, "load_data.jl"))
include(joinpath(@__DIR__, "Individual.jl"))
include(joinpath(@__DIR__, "greedy_split.jl"))
include(joinpath(@__DIR__, "plot.jl"))
include(joinpath(@__DIR__, "Fitness.jl"))
# include(joinpath(@__DIR__, "crossover.jl"))  # To be implemented
# include(joinpath(@__DIR__, "mutation.jl"))   # To be implemented


# =========== Parameters ============
const INSTANCE_PATH = "data/train_0.json"
const POP_SIZE = 100
const MAX_GENERATIONS = 50
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

    # Fill in splits
    population_splits!(population, instance)
    
    # Fill in fitness of initial population
    population_fitness!(population, instance.travel_times, NURSE_PENALTY_FACTOR)

    # Evolution loop
    for gen in 1:MAX_GENERATIONS
        # TODO: Selection (e.g., tournament, roulette wheel)
        parents = population # Placeholder for selection

        offspring = Individual[]
        
        # TODO: Crossover + Mutation to fill offspring population
        while length(offspring) < POP_SIZE
            # TODO: p1, p2 = select_parents(parents)
            # TODO: child = crossover(p1, p2)
            # TODO: mutate!(child)
            
            # For now, just copy a random parent so the code runs
            parent = rand(parents)
            child = Individual(copy(parent.genotype))
            push!(offspring, child)
        end

        # Fill in splits
        population_splits!(offspring, instance)
        
        # Fill in fitness of offspring population
        population_fitness!(offspring, instance.travel_times, NURSE_PENALTY_FACTOR)
        # TODO: Survivor Selection (e.g., elitism, generational replacement)

        population = offspring # Placeholder for survivor selection
        
        # 5. Logging
        current_best = population[1]
        avg_fitness = mean(ind.fitness for ind in population)
        
        println("Gen $gen | Best: $(round(current_best.fitness, digits=2)) | Avg: $(round(avg_fitness, digits=2))")
    
    end

    println("\n--- GA Loop Finished ---")
    println("Final Best Fitness: $(population[1].fitness)")
    println("Genotype: $(population[1].genotype)")

    # Plot the best solution
    println("Plotting best solution...")

    # Placeholder to test plot
    population[1].splits = greedy_split(population[1].genotype, instance) 
    println("Route splits (indices for each split): $(population[1].splits)")

    plot_routes(instance, population[1])
end

# Run the script
main()