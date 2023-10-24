"""
    plot_abundances(SD::Simulation_Data)

plots the total abundances of a species over time
"""
function plot_abundances(SD::Simulation_Data)
    total_abundance = vec(sum(sum(SD.species[1].abundances; dims=1); dims=2))
    x = 1:length(total_abundance)
    carry = fill(
        sum(SD.species[1].vars.carry .* SD.species[1].vars.habitat), length(total_abundance)
    )
    f = Figure(; fontsize = 24)
    ax = Axis(f[1, 1], title="Species Abundance over Time", 
    xlabel = "timestep",
    ylabel = "total abundance")

    lines!(ax, x, total_abundance, label = "Abundance", linewidth = 4)
    lines!(ax, x, carry, label = "Carrying Capacity", linewidth = 4)
    CairoMakie.ylims!(ax, 0, maximum(total_abundance)+20)
    axislegend()
    return f

end

"""
    image_abundances(SD::Simulation_Data, t::Int)

plots the species abundance in the landscape for a given timestep t
"""
function image_abundances(SD::Simulation_Data, t::Int)
    abundance = SD.species[1].abundances[:, :, t]
    f = Figure()
    ax = Axis(f[1,1]; title="Abundance at Timestep $t", 
    )
    hm = CairoMakie.heatmap!(ax, abundance, colormap = :YlGnBu, yflip=true)
    Colorbar(f[1,2],hm)
    return f
end

"""
    image_suitability(SD::Simulation_Data, t::Int)

plots the habitat suitability of a landscape for a given timestep t
"""
function image_suitability(SD::Simulation_Data, t::Int)
    suitability = SD.species[1].habitat[:, :, t]
    f = Figure()
    ax = Axis(f[1,1]; title="Habitat Suitability at Timestep $t", 
    )
    hm = CairoMakie.heatmap!(ax, suitability, colormap = :YlOrBr, yflip=true)
    Colorbar(f[1,2],hm)
    return f
end

"""
    image_temperature(SD::Simulation_Data, t::Int)

plots the temperature of a landscape for a given timestep t
"""
function image_temperature(SD::Simulation_Data, t::Int)
    temp = SD.landscape.environment["temperature"][:, :, t]
    f = Figure()
    ax = Axis(f[1,1]; title="Temperature at Timestep $t")
    hm = CairoMakie.heatmap!(ax, temp, colormap=:plasma, yflip=true)
    Colorbar(f[1,2],hm)
    return f
end

"""
    image_precipitation(SD::Simulation_Data, t::Int)

plots the precipitation of a landscape for a given timestep t
"""
function image_precipitation(SD::Simulation_Data, t::Int)
    prec = SD.landscape.environment["precipitation"][:, :, t]
    f = Figure()
    ax = Axis(f[1,1]; title="Precipitation at Timestep $t")
    hm = CairoMakie.heatmap!(ax, prec, colormap=:viridis, yflip=true)
    Colorbar(f[1,2],hm)
    return f
end

"""
    image_restrictions(SD::Simulation_Data, t::Int)

plots the restrictions of a landscape for a given timestep t
"""
function image_restrictions(SD::Simulation_Data, t::Int)
    restr = SD.landscape.restrictions[:, :, t]
    f = Figure()
    ax = Axis(f[1,1]; title="Restrictions at Timestep $t")
    hm = CairoMakie.heatmap!(ax, restr, colormap=:grays, yflip=true)
    Colorbar(f[1,2],hm)
    return f
end

"""
    abundance_gif(SD::Simulation_Data, frames=2)

creates a gif for the abundance of a species in a landscape for all timesteps
"""
function abundance_gif(SD::Simulation_Data, frames=20)
    timesteps = size(SD.species[1].abundances, 3)
    fig = Figure()
    record(fig, "Abundances.gif", 1:timesteps, framerate=frames) do i
        image_abundances(SD,i)
    end

    # timesteps = size(SD.species[1].abundances, 3)
    # #fig = Figure()
    # for i in 1:timesteps
    #     abund = SD.species[1].habitat[:, :, i]
    #     fig = Figure()
    #     ax = Axis(fig[1,1]; title="Abundances at Timestep $i")
    #     hm = heatmap!(ax,abund;yflip=true,)
    #     fig 
    # end
    #return fig
    # t = Observable(1)
    # timesteps = size(SD.species[1].abundances, 3)
    # fig = Figure()
    # ax = Axis(fig[1,1]; title="Abundances at Timestep $t")
    # l1 = on(t) do val
    #     hm = CairoMakie.heatmap!(ax,SD.species[1].abundances[:, :, val], colormap=:grays, yflip=true)
    # end
    # record(fig, "Abundances.gif", 1:timesteps, framerate=frames) do i
    #     t[] = i
    # end
    # t = size(SD.species[1].abundances, 3)
    # max_ab = maximum(skipmissing(SD.species[1].abundances))
    # fig = Figure()
    #ax = Axis(fig[1,1]; title="Abundances at Timestep $t")
    #hm = heatmap(ax, SD.species[1].abundances[:, :, 1])
    # record(fig, "Abundances.gif",1:t, framerate = frames) do i 
      #   ax = Axis(fig[1,1]; title="Abundances at Timestep $i")
         #hm = heatmap(SD.species[1].abundances[:, :, i])
         #Colorbar(fig[1,2])
    #end
end

"""
    suitability_gif(SD::Simulation_Data, frames=2)

creates a gif for the habitat suitability of a landscape for all timesteps
"""
function suitability_gif(SD::Simulation_Data, frames=2)
    # t = size(SD.species[1].habitat, 3)
    # anim = @animate for i in 1:t
    #     heatmap(
    #         SD.species[1].habitat[:, :, i];
    #         title="Habitat Suitability at Timestep $i",
    #         c=:YlOrBr,
    #         clims=(0, 1),
    #         yflip=true,
    #     )
    # end
    # return gif(anim, "Suitability.gif"; fps=frames)
end

function plot_all_cairo(SD::Simulation_Data, t::Int)
    temp = reverse(SD.landscape.environment["temperature"][:, :, t]')
    prec = reverse(SD.landscape.environment["precipitation"][:, :, t]')
    suitability = reverse(SD.species[1].habitat[:, :, t]')
    abundance = reverse(SD.species[1].abundances[:, :, t]')
    start_prec = minimum(filter(!isnan,prec))
    stop_prec = maximum(filter(!isnan,prec))
    start_temp = minimum(filter(!isnan,temp))
    stop_temp = maximum(filter(!isnan,temp))
    x_prec = collect(range(0; stop=(stop_prec*2), length=1000)) #TODO find better start-stop
    y_prec = get_habitat_suit(
        SD.species[1].traits.env_preferences["precipitation"].upper_limit,
        SD.species[1].traits.env_preferences["precipitation"].optimum,
        SD.species[1].traits.env_preferences["precipitation"].lower_limit,
        x_prec,
    )
    x_temp = collect(range((start_temp-start_temp/10); stop=(stop_temp+(stop_temp/10)), length=1000)) #TODO find better start-stop
    y_temp = get_habitat_suit(
        SD.species[1].traits.env_preferences["temperature"].upper_limit,
        SD.species[1].traits.env_preferences["temperature"].optimum,
        SD.species[1].traits.env_preferences["temperature"].lower_limit,
        x_temp,
    )

    f = Figure(; resolution=(1200,800), figure_padding=1)

    ratio = size(SD.species[1].abundances,1)/size(SD.species[1].abundances,2)

    box_size_l = 12

    box_size_r = 7

    plot_size = 4

    f_left = f[1:2, 1:6] = GridLayout()
    f_right = f[1:2, 7:9] = GridLayout()

    box_left = Box(
        f_left[1:(box_size_l-2), 1:box_size_l];
        color=(:gray80, 0.5),
        alignmode=Outside(),
        strokecolor=:black,
        #padding=(50, 80, 80, 50),
    )

    box_right = Box(
        f_right[1:(box_size_l-2), 1:box_size_r];
        color=(:white, 0.5),
        alignmode=Outside(),
        strokecolor=:black,
    )

    title_left = Label(
        f_left[1, 2:(box_size_l - 1), Top()],
        "Input parameters";
        fontsize=26,
        font=:bold,
        padding=(0, 20, 20, 0),
    )

    title_right = Label(
        f_right[1, 2:(box_size_r - 1), Top()],
        "Output";
        fontsize=26,
        font=:bold,
        padding=(0, 20, 20, 0),
    )

    ax1 = Axis(f_left[2:(1 + plot_size), 2:(1 + plot_size)]; 
    title="Temperature tolerance", xlabel = "temperature [K]", 
    ylabel = "fitness",
    )
    tol_t = CairoMakie.lines!(ax1, x_temp, y_temp)

    ax2 = Axis(
        f_left[2:(1 + plot_size), (3 + plot_size):(2 + plot_size * 2)];
        title="Precipitation tolerance", xlabel = "precipitation [mm]",
         ylabel = "fitness",
    )
    tol_p = CairoMakie.lines!(ax2, x_prec, y_prec)

    ax3 = Axis(
        f_left[(2 + plot_size):(1 + plot_size * 2), 2:(1 + plot_size)]; 
        title="Temperature at t = $t", aspect = ratio
    )
    hm3 = CairoMakie.heatmap!(ax3, temp, colormap=:plasma)
    Colorbar(f_left[(2 + plot_size):(1 + plot_size * 2), 2 + plot_size], hm3)
    ax3.xreversed = true
    ax4 = Axis(
        f_left[(2 + plot_size):(1 + plot_size * 2), (3 + plot_size):(2 + plot_size * 2)];
        title="Precipitation at t = $t", aspect = ratio
    )
    hm4 = CairoMakie.heatmap!(ax4, prec, colormap=:viridis)
    Colorbar(f_left[(2 + plot_size):(1 + plot_size * 2), 3 + plot_size*2], hm4)
    ax4.xreversed = true
    ax5 = Axis(f_right[2:(1 + plot_size), 2:(1 + plot_size)]; 
    title="Habitat Suitability at t = $t", aspect = ratio)
    hm5 = CairoMakie.heatmap!(ax5, suitability, colormap=:YlOrBr)
    Colorbar(f_right[2:(1 + plot_size),  (box_size_r-1)], hm5)
    ax5.xreversed = true
    ax6 = Axis(
        f_right[(2 + plot_size):(1 + plot_size * 2), 2:(1 + plot_size)]; 
        title="Abundance at t = $t", aspect = ratio
    )
    hm6 = CairoMakie.heatmap!(ax6, abundance, colormap=:YlGnBu)
    Colorbar(f_right[(2 + plot_size):(1 + plot_size * 2),  (box_size_r-1)], hm6)
    ax6.xreversed = true
    return f
end
