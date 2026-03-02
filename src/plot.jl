using Plots
ENV["GKSwstype"] = "100" # Headless mode (stops popup)
gr()

function plot_routes(instance::Instance, ind::Individual, pop_size::Int, generations::Int, percentage::Float64)
    split_indices = ind.splits
    title::String = "With population of $pop_size over $generations generations:\n Fitness: $(round(ind.fitness, digits=2)), "
    if percentage < 0
        title = title * "$(-percentage)% better than benchmark."
    else 
        title = title * "$(percentage)% worse than benchmark."
    end
    
    p = plot(title=title,
             xlabel="X Coordinate", ylabel="Y Coordinate", 
             aspect_ratio=:equal, 
             legend=:outertopright,
             grid=false,
             size=(1000, 1000), 
             dpi=600,
             background_color=:white,
             framestyle=:box)

    colors = palette(:tab20)

    # --- Plot Routes ---
    start_idx = 1
    
    for (i, end_idx) in enumerate(split_indices)
        
        # Build coordinate lists for the nurse's path
        xs = [instance.depot.x_coord]
        ys = [instance.depot.y_coord]
        
        for k in start_idx:end_idx
            p_id = ind.genotype[k]
            pat = instance.patients[p_id] 
            push!(xs, pat.x_coord)
            push!(ys, pat.y_coord)
        end
        
        # Return to Depot
        push!(xs, instance.depot.x_coord)
        push!(ys, instance.depot.y_coord)
        
        # Plot the route line
        plot!(p, xs, ys, 
              label="Nurse $i", 
              color=colors[mod1(i, length(colors))], 
              linewidth=1.2, 
              alpha=0.9)
        
        # Update start_idx for the NEXT nurse
        start_idx = end_idx + 1
    end

    # --- Plot Patients (Black Squares) ---
    pat_xs = [p.x_coord for p in instance.patients]
    pat_ys = [p.y_coord for p in instance.patients]
    
    scatter!(p, pat_xs, pat_ys, 
             label="Patients", 
             shape=:square, 
             color=:black, 
             markersize=2.5, 
             markerstrokewidth=0)

    # --- Plot Depot (Black Circle) ---
    scatter!(p, [instance.depot.x_coord], [instance.depot.y_coord], 
             label="Depot", 
             color=:black, 
             markersize=8, 
             shape=:circle)

    # Ensure the directory exists before saving
    mkpath("plots")
    savefig(p, "plots/$(instance.instance_name)_solution_plot.png") 
    display(p)
    println("Press Enter to close the plot...")
    readline()
    return p
end