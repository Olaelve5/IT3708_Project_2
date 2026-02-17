include("Individual.jl")

#Decodes individual to a list of lists where each inner list represents a nurse route.
function greedy_decode(individual::Individual)::Vector{Vector{Int}}
    routes = Vector{Vector{Int}}()
    prev = 0
    for split_idx in individual.splits
        push!(routes, individual.genotype[prev + 1:split_idx])
        prev = split_idx
    end
    return routes
end

#Mutates
function greedy_encode!(individual::Individual, routes::Vector{Vector{Int}})
    individual.genotype = vcat(routes...)
    
    # Recompute splits as cumulative end indices
    individual.splits = cumsum(length.(routes))
end