include("individual.jl")

function tournament_selection(population::Vector{Individual}, tournament_size::Int)::Individual
    # Pick tournament_size random individuals and return the best
    contestants = population[rand(1:length(population), tournament_size)]
    return contestants[argmin(ind.fitness for ind in contestants)]
end

function select_parents(population::Vector{Individual}, tournament_size::Int=3)::Tuple{Individual, Individual}
    p1 = tournament_selection(population, tournament_size)
    p2 = tournament_selection(population, tournament_size)
    return p1, p2
end