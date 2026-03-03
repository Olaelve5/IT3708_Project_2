include("Individual.jl")
include("greedy_encode_decode.jl")
include("greedy_split.jl")

function route_crossover(parent1::Individual, parent2::Individual, instance::Instance)::Tuple{Individual, Individual}
    # Child 1 ----------------------->
    routes1 = greedy_decode(parent1)
    routes2 = greedy_decode(parent2)

    # Fallback for individuals without route structure.
    if isempty(routes1) || isempty(routes2)
        return order_crossover(parent1, parent2)
    end

    # Pick a random route from parent1
    selected_route1 = routes1[rand(1:length(routes1))]
    selected_set1 = Set(selected_route1)

    # Get remaining patients in parent2's order
    remaining2 = [p for p in parent2.genotype if p ∉ selected_set1]

    # Insert selected route at a random position
    position1 = rand(0:length(remaining2))
    child1_genotype = vcat(remaining2[1:position1], selected_route1, remaining2[position1 + 1:end])
    child1 = Individual(child1_genotype)

    # Child 2 ----------------------->
    # Pick a random route from parent2
    selected_route2 = routes2[rand(1:length(routes2))]
    selected_set2 = Set(selected_route2)

    # Get remaining patients in parent1's order
    remaining1 = [p for p in parent1.genotype if p ∉ selected_set2]

    # Insert selected route at a random position
    position2 = rand(0:length(remaining1))
    child2_genotype = vcat(remaining1[1:position2], selected_route2, remaining1[position2 + 1:end])
    child2 = Individual(child2_genotype)

    return child1, child2
end


function order_crossover(parent1::Individual, parent2::Individual)::Tuple{Individual, Individual}
    n = length(parent1.genotype)
    cut1, cut2 = rand(1:n), rand(1:n)
    if cut1 > cut2
        cut1, cut2 = cut2, cut1
    end

    child1 = fill(0, n)
    child2 = fill(0, n)

    # Copy middle segments from opposite parents.
    child1[cut1:cut2] = parent1.genotype[cut1:cut2]
    child2[cut1:cut2] = parent2.genotype[cut1:cut2]

    function fill_ox_child!(child::Vector{Int}, donor::Vector{Int}, c1::Int, c2::Int)
        insert_pos = (c2 % n) + 1
        donor_pos = (c2 % n) + 1
        child_set = Set(child[c1:c2])

        inserted = 0
        needed = n - (c2 - c1 + 1)

        while inserted < needed
            gene = donor[donor_pos]
            if !(gene in child_set)
                child[insert_pos] = gene
                push!(child_set, gene)
                inserted += 1
                insert_pos = (insert_pos % n) + 1
                while c1 <= insert_pos <= c2
                    insert_pos = (insert_pos % n) + 1
                end
            end
            donor_pos = (donor_pos % n) + 1
        end
    end

    fill_ox_child!(child1, parent2.genotype, cut1, cut2)
    fill_ox_child!(child2, parent1.genotype, cut1, cut2)

    return Individual(child1), Individual(child2)
end


function mixed_crossover(parent1::Individual, parent2::Individual, instance::Instance;
                         route_share::Float64=0.6)::Tuple{Individual, Individual}
    if rand() < route_share
        return route_crossover(parent1, parent2, instance)
    end
    return order_crossover(parent1, parent2)
end
