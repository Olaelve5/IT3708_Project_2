include(joinpath(@__DIR__, "load_data.jl"))


function prins_algo(genotype::Vector{Int}, instance::Instance)
    n = length(genotype)
    best_travel_times = fill(Inf, n + 1)
    best_travel_times[1] = 0.0
    best_splits = fill(0, n + 1)

    for i in 1:n
        route_load = 0
        route_clock = 0.0
        route_travel = 0.0
        prev_matrix_idx = 1  # start from depot

        for j in i:n
            patient_id = genotype[j]
            patient = instance.patients[patient_id]

            # depot is idx 1, so add 1 to patient_id for matrix indexing
            curr_matrix_idx = patient_id + 1

            # check capacity
            route_load += patient.demand
            if route_load > instance.capacity_nurse
                break
            end

            # drive to this patient
            drive_time = instance.travel_times[prev_matrix_idx, curr_matrix_idx]
            route_travel += drive_time
            arrival_time = route_clock + drive_time

            # too late
            if arrival_time > patient.end_time
                break
            end

            # wait if we're early, then perform care
            start_care_time = max(arrival_time, patient.start_time)
            route_clock = start_care_time + patient.care_time

            # make sure we can get back to the depot in time
            drive_home_time = instance.travel_times[curr_matrix_idx, 1]
            if route_clock + drive_home_time > instance.depot.return_time
                break
            end

            # try updating the shortest path
            total_trip_travel = route_travel + drive_home_time
            candidate = best_travel_times[i] + total_trip_travel
            if candidate < best_travel_times[j + 1]
                best_travel_times[j + 1] = candidate
                best_splits[j + 1] = i - 1
            end
            prev_matrix_idx = curr_matrix_idx
        end
    end

    formatted_best_splits = extract_end_indices(best_splits, n)

    return best_travel_times[n + 1], formatted_best_splits
end



function extract_end_indices(best_splits::Vector{Int}, n::Int)
    end_indices = Int[]
    current_end = n
    
    while current_end > 0
        push!(end_indices, current_end)
        current_end = best_splits[current_end + 1]
    end
    
    reverse!(end_indices) 
    
    return end_indices
end