function swap_mutation!(ind::Individual, mutation_rate::Float64)
    """
    Swaps two random genes in the individual's genotype with a given mutation rate.
    """
    
    if rand() < mutation_rate
        n = length(ind.genotype)

        # Pick two random unique indices and swap their values
        idx1 = rand(1:n)
        idx2 = rand(1:n)
        while idx2 == idx1
            idx2 = rand(1:n)
        end
        ind.genotype[idx1], ind.genotype[idx2] = ind.genotype[idx2], ind.genotype[idx1]
        
        # Set fitness to 0.0 to indicate it needs re-evaluation
        ind.fitness = 0.0 
    end
end


function reversal_mutation!(ind::Individual, mutation_rate::Float64)
    """
    Reverses a random segment of the individual's genotype with a given mutation rate.
    """
    
    if rand() < mutation_rate
        n = length(ind.genotype)
        
        # Pick two random indices and sort them
        idx1 = rand(1:n)
        idx2 = rand(1:n)
        
        if idx1 > idx2
            idx1, idx2 = idx2, idx1
        end
        
        # Only reverse if they are different to avoid unnecessary operations
        if idx1 != idx2
            reverse!(ind.genotype, idx1, idx2)

            # Reset fitness and splits to indicate it needs re-evaluation
            ind.fitness = 0.0
            ind.splits = Int[]
        end
    end
end
