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
            distance += travel_matrix[last_patient, current_patient] # To-patient travel
            last_patient = current_patient
        end
        distance += travel_matrix[last_patient, 1] # Back to depot
        last_split = split
    end
    return distance
end

"""
Returns fitness of individual based on total driving distance and
penalty if enabled.
"""
function individual_fitness(individual::Individual, instance::Instance, penalty_factor::Float64)::Float64
    fitness = individual_distance(individual, instance.travel_times)
    # TODO: Add more penalty functions...?
    penalty = count_missed_patients(individual, instance.nbr_nurses)
    penalty_scaled = penalty * penalty_factor
    return fitness += penalty_scaled
end

"""Sets fitness of entire population as in place operation."""
function population_fitness!(population::Vector{Individual}, instance::Instance, penalty_factor::Float64)
    for individual in population
        individual.fitness = individual_fitness(individual, instance, penalty_factor)
    end
end

function count_missed_patients(individual::Individual, n_nurses::Int)
    nurses_used = length(individual.splits)

    if nurses_used ≤ n_nurses
        return 0
    else
        last_feasible_patient_idx = individual.splits[n_nurses]
        n_patients_over = length(individual.genotype) - last_feasible_patient_idx
        return n_patients_over
    end
end