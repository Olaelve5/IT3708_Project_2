using JSON3

struct Depot
    return_time::Int
    x_coord::Int
    y_coord::Int
end

struct Patient
    id::Int
    x_coord::Int
    y_coord::Int
    demand::Int
    start_time::Int
    end_time::Int
    care_time::Int
end

struct Instance
    instance_name::String
    nbr_nurses::Int
    capacity_nurse::Int
    benchmark::Float64
    depot::Depot
    patients::Vector{Patient}
    travel_times::Matrix{Float64}
end

function load_instance(path::AbstractString)::Instance
    raw = JSON3.read(read(path, String))

    # depot
    dep = raw["depot"]
    depot = Depot(
        Int(dep["return_time"]),
        Int(dep["x_coord"]),
        Int(dep["y_coord"]),
    )

    # patients: JSON has keys like "1", "2", ... -> convert to Int and sort
    pats_obj = raw["patients"]
    ids = sort(parse.(Int, collect(keys(pats_obj))))

    patients = Vector{Patient}(undef, length(ids))
    for (i, id) in enumerate(ids)
        p = pats_obj[string(id)]
        patients[i] = Patient(
            id,
            Int(p["x_coord"]),
            Int(p["y_coord"]),
            Int(p["demand"]),
            Int(p["start_time"]),
            Int(p["end_time"]),
            Int(p["care_time"]),
        )
    end

    # travel_times: JSON nested arrays -> Matrix{Float64}
    tt_rows = raw["travel_times"]
    n = length(tt_rows)
    travel_times = Matrix{Float64}(undef, n, n)
    for i in 1:n
        row = tt_rows[i]
        @inbounds for j in 1:n
            travel_times[i, j] = Float64(row[j])
        end
    end

    return Instance(
        String(raw["instance_name"]),
        Int(raw["nbr_nurses"]),
        Int(raw["capacity_nurse"]),
        Float64(raw["benchmark"]),
        depot,
        patients,
        travel_times,
    )
end
