include(joinpath(@__DIR__, "Individual.jl"))

function elitism(old_pop::Vector{Individual}, new_pop::Vector{Individual}, elite_size::Int)::Vector{Individual}
    sorted_old = sort(old_pop, by = ind -> ind.fitness)
    sorted_new = sort(new_pop, by = ind -> ind.fitness)

    elites = sorted_old[1:elite_size]
    non_elites = sorted_new[1:(length(new_pop) - elite_size)]
    
    return vcat(elites, non_elites)
end