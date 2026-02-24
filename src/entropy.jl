function calculate_population_entropy(population::Vector{Individual})::Float64
    pop_size = length(population)
    
    if pop_size == 0 || length(population[1].genotype) <= 1
        return 0.0
    end
    
    num_patients = length(population[1].genotype)
    total_entropy = 0.0

    for i in 1:num_patients
        counts = Dict{Int, Int}()
        for ind in population
            patient_id = ind.genotype[i]
            counts[patient_id] = get(counts, patient_id, 0) + 1
        end

        position_entropy = 0.0
        for count in values(counts)
            p = count / pop_size
            position_entropy -= p * log2(p)
        end
        
        total_entropy += position_entropy
    end

    avg_raw_entropy = total_entropy / num_patients
    max_entropy = log2(num_patients)
    normalized_entropy = (avg_raw_entropy / max_entropy) * 100.0
    
    return normalized_entropy
end