include("individual.jl")
include("greedy_encode_decode.jl")
include("greedy_split.jl")

function route_crossover(parent1::Individual, parent2::Individual, instance::Instance)::Tuple{Individual, Individual}
    # Child 1 ----------------------->
    routes1 = greedy_decode(parent1)
    
    # Pick a random route from parent1
    selected_route1 = routes1[rand(1:length(routes1))]
    selected_set1 = Set(selected_route1)

    # Get remaining patients in parent2's order
    remaining2 = [p for p in parent2.genotype if p ∉ selected_set1]

    # Insert selected route at a random position
    position1 = rand(0:length(remaining2))
    child1_genotype = vcat(remaining2[1:position1], selected_route1, remaining2[position1+1:end])
    child1 = Individual(child1_genotype)

    # Child 2 ----------------------->
    routes2 = greedy_decode(parent2)
    
    # Pick a random route from parent2
    selected_route2 = routes2[rand(1:length(routes2))]
    selected_set2 = Set(selected_route2)

    # Get remaining patients in parent1's order
    remaining1 = [p for p in parent1.genotype if p ∉ selected_set2]

    # Insert selected route at a random position
    position2 = rand(0:length(remaining1))
    child2_genotype = vcat(remaining1[1:position2], selected_route2, remaining1[position2+1:end])
    child2 = Individual(child2_genotype)

    # Return both children as a tuple
    return child1, child2
end