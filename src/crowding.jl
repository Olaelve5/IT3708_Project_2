include(joinpath(@__DIR__, "edge_distance.jl"))

function deterministic_crowding(p1, p2, c1, c2)
    # Calculate edge distances
    d11 = edge_distance(p1.genotype, c1.genotype)
    d12 = edge_distance(p1.genotype, c2.genotype)
    d21 = edge_distance(p2.genotype, c1.genotype)
    d22 = edge_distance(p2.genotype, c2.genotype)

    if (d11 + d22) <= (d12 + d21)
        survivor1 = (c1.fitness < p1.fitness) ? c1 : p1
        survivor2 = (c2.fitness < p2.fitness) ? c2 : p2
    else
        survivor1 = (c2.fitness < p1.fitness) ? c2 : p1
        survivor2 = (c1.fitness < p2.fitness) ? c1 : p2
    end

    return survivor1, survivor2
end