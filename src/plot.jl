using Plots
ENV["GKSwstype"] = "100" # Headless mode (stops popup)
gr()

function plot_routes(
    instance::Instance,
    ind::Individual,
    pop_size::Int,
    generations::Int,
    percentage::Float64)

    split_indices = ind.splits
    title::String = "With population of $pop_size over $generations generations:\n Fitness: $(round(ind.fitness, digits=2)), "
    if percentage < 0
        title = title * "$(-round(percentage, digits=2))% better than benchmark."
    else 
        title = title * "$(round(percentage, digits=2))% worse than benchmark."
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
    mkpath("plots/solutions")
    savefig(p, "plots/solutions/$(instance.instance_name)_solution_plot.png") 
    return p
end


function plot_convergence(fitness_history::Vector{Float64}, entropy_history::Vector{Float64}, instance_name::String)
    # Create the top plot (Fitness)
    p1 = plot(fitness_history, 
              title="Convergence History: $instance_name", 
              ylabel="Best Fitness", 
              label=false, 
              color=:blue, 
              linewidth=2)

    # Create the bottom plot (Entropy)
    p2 = plot(entropy_history, 
              ylabel="Entropy (%)", 
              xlabel="Generations", 
              label=false, 
              color=:green, 
              linewidth=2)

    # Combine them into a stacked layout (2 rows, 1 column) and link the X-axis
    final_plot = plot(p1, p2, layout=(2, 1), size=(800, 600), link=:x, margin=5Plots.mm)

    # Save as PDF
    mkpath("plots/convergence")
    filename = "plots/convergence/convergence_$(instance_name).pdf"
    savefig(final_plot, filename)
    println("Saved convergence plot to $filename")
end

