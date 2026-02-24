function edge_distance(geno1::Vector{Int}, geno2::Vector{Int})::Int
    edges1 = Set{Tuple{Int, Int}}()
    for i in 1:(length(geno1)-1)
        push!(edges1, (geno1[i], geno1[i+1]))
    end
    
    distance = 0
    for i in 1:(length(geno2)-1)
        edge = (geno2[i], geno2[i+1])
        if !(edge in edges1)
            distance += 1
        end
    end
    
    return distance
end