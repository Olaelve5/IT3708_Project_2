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
<<<<<<< Updated upstream
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
=======
>>>>>>> Stashed changes
        ind.splits = Int[]
    end
end


function reversal_mutation!(ind::Individual, mutation_rate::Float64)
    """
    Reverses a short random segment of the individual's genotype with a given mutation rate.
    """
    if rand() >= mutation_rate
        return
    end

    n = length(ind.genotype)
    max_len = max(2, min(n, round(Int, 0.2 * n)))
    segment_len = rand(2:max_len)
    start_idx = rand(1:(n - segment_len + 1))
    end_idx = start_idx + segment_len - 1

    reverse!(ind.genotype, start_idx, end_idx)
    ind.fitness = Inf
    ind.splits = Int[]
end


function insertion_mutation!(ind::Individual, mutation_rate::Float64)
    """
    Removes one gene and inserts it at a new position.
    """
    if rand() >= mutation_rate
        return
    end

    n = length(ind.genotype)
    i, j = rand(1:n), rand(1:n)
    while i == j
        j = rand(1:n)
    end

    gene = ind.genotype[i]
    deleteat!(ind.genotype, i)
    if i < j
        j -= 1
    end
    insert!(ind.genotype, j, gene)

    ind.fitness = Inf
    ind.splits = Int[]
end


function hybrid_mutation!(ind::Individual, overall_mutation_rate::Float64;
                          swap_share::Float64=0.2,
                          reversal_share::Float64=0.6,
                          insertion_share::Float64=0.2)
    if rand() >= overall_mutation_rate
        return
    end

    total_share = swap_share + reversal_share + insertion_share
    if total_share <= 0.0
        return
    end

    r = rand()
    swap_cutoff = swap_share / total_share
    reversal_cutoff = (swap_share + reversal_share) / total_share

    if r < swap_cutoff
        swap_mutation!(ind, 1 / length(ind.genotype))
    elseif r < reversal_cutoff
        reversal_mutation!(ind, 1.0)
    else
        insertion_mutation!(ind, 1.0)
    end
end
