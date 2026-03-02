function swap_mutation!(ind::Individual, mutation_rate::Float64)
    """
    Swaps random genes in the individual's genotype with a given mutation rate.
    """

    n = length(ind.genotype)
    has_mutated = false

    for i in 1:n
        if rand() < mutation_rate
            j = rand(1:n)
            
            ind.genotype[i], ind.genotype[j] = ind.genotype[j], ind.genotype[i]
            has_mutated = true
        end
    end
    
    if has_mutated
        ind.fitness = Inf
    end
end


function reversal_mutation!(ind::Individual, mutation_rate::Float64)
    """
    Reverses a random segment of the individual's genotype with a given mutation rate.
    """
    n = length(ind.genotype)
        
    # Pick two random indices and sort them
    idx1 = rand(1:n-1)
    
    max_length = min(n - idx1, 10) 
    idx2 = idx1 + rand(1:max_length)
        
    if idx1 > idx2
        idx1, idx2 = idx2, idx1
    end
        
    # Only reverse if they are different to avoid unnecessary operations
    if idx1 != idx2
        reverse!(ind.genotype, idx1, idx2)

        # Reset fitness and splits to indicate it needs re-evaluation
        ind.fitness = Inf
        ind.splits = Int[]
    end
end


function hybrid_mutation!(ind::Individual, overall_mutation_rate::Float64)
    if rand() < overall_mutation_rate
        if rand() < 0.3
            swap_mutation!(ind, 1/length(ind.genotype))
        else
            reversal_mutation!(ind, 1.0)
        end
    end
end