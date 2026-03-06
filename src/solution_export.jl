include(joinpath(@__DIR__, "Individual.jl"))

function export_solution(individual::Individual, instance::Instance, filepath::String)
    splits = individual.splits
    genotype = individual.genotype

    routes = Vector{Vector{Int}}()
    prev = 0
    for s in splits
        push!(routes, genotype[prev+1:s])
        prev = s
    end

    open(filepath, "w") do io
        println(io, "Nurse capacity: $(instance.capacity_nurse)")
        println(io, "Depot return time: $(instance.depot.return_time)")
        println(io, "-"^120)

        for (nurse_idx, route) in enumerate(routes)
            route_load = 0
            route_travel = 0.0
            clock = 0.0
            prev_matrix_idx = 1

            segments = String[]
            push!(segments, "D(0)")

            for patient_id in route
                patient = instance.patients[patient_id]
                curr_matrix_idx = patient_id + 1

                route_load += patient.demand

                drive_time = instance.travel_times[prev_matrix_idx, curr_matrix_idx]
                route_travel += drive_time
                arrival_time = clock + drive_time

                start_care = max(arrival_time, Float64(patient.start_time))
                end_care = start_care + patient.care_time
                clock = end_care

                push!(segments, "$(patient_id)($(round(start_care, digits=2))-$(round(end_care, digits=2))) [$(patient.start_time)-$(patient.end_time)]")

                prev_matrix_idx = curr_matrix_idx
            end

            drive_home = instance.travel_times[prev_matrix_idx, 1]
            route_travel += drive_home
            return_time = clock + drive_home

            push!(segments, "D ($(round(return_time, digits=2)))")

            sequence_str = join(segments, " -> ")

            println(io, "Nurse $(nurse_idx)\t$(round(route_travel, digits=2))\t$(route_load)\t$(sequence_str)")
        end

        println(io, "-"^120)
        println(io, "Objective value (total duration): $(round(individual.fitness, digits=2))")
    end

    println("Solution exported to: $filepath")
end
