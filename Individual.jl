using Random
Random.seed!(123)

mutable struct Individual
    genotype::Vector{Int} 
    fitness::Float64
    selection_prob::Float64
end

function Individual(num_patients::Int)
    genotype = shuffle(1:num_patients) 
    return Individual(genotype, 0.0, 0.0)
end

# Constructor for a specific genotype  -> used when creating offspring from crossover/mutation
Individual(genotype::Vector{Int}) = Individual(genotype, 0.0, 0.0)

function initialize_population(pop_size::Int, num_patients::Int)
    population = [Individual(num_patients) for _ in 1:pop_size]
    return population
end
