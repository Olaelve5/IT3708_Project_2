"""
Fitness.jl contains functionality for calculating total distance and
the fitness of an individual in the population.
"""

include("./Individual.jl")

"""
This function sums up total distance driven by all nurses in an
individual suggested solution. Is used as standalone fitness function
if fitness function is called with penalty=false.
"""
function individual_distance(individual::Individual, travel_matrix::Matrix{Float64})::Float64
    patients::Vector{Int} = individual.genotype
    distance::Float64 = 0
    last_split::Int = 0

    # Loop through nurses
    for split in individual.splits

    # Loop through genotype indexes (patients) of corresponding nurse and sum distance
        last_patient::Int = 1
        for patient_idx in last_split+1:split
            current_patient = patients[patient_idx]
            distance += travel_matrix[last_patient, current_patient] # To patient travel
            last_patient = current_patient
        end
        distance += travel_matrix[last_patient, 1] # Back to depot
        last_split = split
    end
    return distance
end

"""
Returns fitness of individual based on total driving distance and
penalty if eneabled.
"""
function individual_fitness(individual::Individual, travel_matrix::Matrix{Float64}; penalty::Bool=false)::Float64
    fitness = individual_distance(individual, travel_matrix)
    if penalty
        fitness += 0 # TODO: Add penalty functionality based on... something
    end
    return fitness
end