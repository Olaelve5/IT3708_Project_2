function calculate_population_entropy(population::Vector{Individual})::Float64
    pop_size = length(population)
    
    if pop_size == 0 || length(population[1].genotype) <= 1
        return 0.0
    end
    
    num_patients = length(population[1].genotype)
    edge_counts = Dict{Tuple{Int, Int}, Int}()

    # Count every edge in every genotype
    for ind in population
        for i in 1:(num_patients - 1)
            edge = (ind.genotype[i], ind.genotype[i+1])
            edge_counts[edge] = get(edge_counts, edge, 0) + 1
        end
    end

    total_edges_in_pop = pop_size * (num_patients - 1)
    
    entropy = 0.0
    for count in values(edge_counts)
        p = count / total_edges_in_pop
        entropy -= p * log2(p)
    end

    max_possible_edges = num_patients * (num_patients - 1)
    max_entropy = log2(max_possible_edges)
    min_entropy = log2(num_patients - 1)

    normalized_entropy = ((entropy - min_entropy) / (max_entropy - min_entropy)) * 100.0
    
    return normalized_entropy
end