function greedy_split(genotype::Vector{Int}, instance::Instance)
    route_lengths = Int[]
    
    current_count = 0
    current_load = 0
    current_time = 0.0
    current_loc = 1

    i = 1
    while i <= length(genotype)
        patient_id = genotype[i]
        p_data = instance.patients[patient_id]
        
        # Depot is at index 1, so offset by 1
        patient_mtx_idx = patient_id + 1 

        # Drive: Current -> Patient
        dist_travel = instance.travel_times[current_loc, patient_mtx_idx]
        arrival_time = current_time + dist_travel

        # Wait if early
        start_service = max(arrival_time, Float64(p_data.start_time))
        finish_service = start_service + p_data.care_time

        # Drive: Patient -> Depot
        dist_return = instance.travel_times[patient_mtx_idx, 1]
        return_arrival = finish_service + dist_return

        is_feasible = true
        
        # Check constraints
        if current_load + p_data.demand > instance.capacity_nurse
            is_feasible = false
        end
        
        if start_service > p_data.end_time
            is_feasible = false
        end
        
        if return_arrival > instance.depot.return_time
            is_feasible = false
        end

        if is_feasible
            # Add to current nurse
            current_count += 1
            current_load += p_data.demand
            current_time = finish_service
            current_loc = patient_mtx_idx
            i += 1
        else
            # Split: Close current route
            if current_count == 0
                error("Patient $patient_id is impossible to visit! (Check constraints vs Data)")
            end

            push!(route_lengths, i-1)

            # Reset for NEW nurse
            current_count = 0
            current_load = 0
            current_time = 0.0
            current_loc = 1
        end
    end

    # Save the last route
    if current_count > 0
        push!(route_lengths, i-1)
    end
    
    return route_lengths
end