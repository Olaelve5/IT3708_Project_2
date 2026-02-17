include("load_data.jl")

instance::Instance = load_instance("data/train_0.json")

println(instance.travel_times[1,2])