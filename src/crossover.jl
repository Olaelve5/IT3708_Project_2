include("individual.jl")

function route_crossover(parent1::Individual, parent2::Individual)::Individual
    routes1 = greedy_decode(parent1)

    # Pick a random route from parent1
    selected_route = routes1[rand(1:length(routes1))]
    selected_set = Set(selected_route)

    # Get remaining patients in parent2's order, skipping selected patients
    remaining = [p for p in parent2.genotype if p ∉ selected_set]

    # Insert selected route at a random position in remaining
    position = rand(0:length(remaining))
    child_genotype = vcat(remaining[1:position], selected_route, remaining[position+1:end])

    return Individual(child_genotype)
end