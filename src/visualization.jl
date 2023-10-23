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
    plot(
        x,
        [total_abundance carry];
        title="Species Abundance over Time",
        label=["Abundance" "Carrying Capacity"],
    )
    xlabel!("timestep")
    ylabel!("total abundance")
    return ylims!(0, maximum(total_abundance))
end

"""
    image_abundances(SD::Simulation_Data, t::Int)

plots the species abundance in the landscape for a given timestep t
"""
function image_abundances(SD::Simulation_Data, t::Int)
    abundance = SD.species[1].abundances[:, :, t]
    return heatmap(
        abundance; title="Species Abundance at Timestep $t", c=:YlGnBu, yflip=true
    )
end

"""
    image_suitability(SD::Simulation_Data, t::Int)

plots the habitat suitability of a landscape for a given timestep t
"""
function image_suitability(SD::Simulation_Data, t::Int)
    suitability = SD.species[1].habitat[:, :, t]
    return heatmap(
        suitability; title="Habitat Suitability at Timestep $t", c=:YlOrBr, yflip=true
    )
end

"""
    image_temperature(SD::Simulation_Data, t::Int)

plots the temperature of a landscape for a given timestep t
"""
function image_temperature(SD::Simulation_Data, t::Int)
    temp = SD.landscape.environment["temperature"][:, :, t]
    return heatmap(temp; title="Temperature at Timestep $t", c=:plasma, yflip=true)
end

"""
    image_precipitation(SD::Simulation_Data, t::Int)

plots the precipitation of a landscape for a given timestep t
"""
function image_precipitation(SD::Simulation_Data, t::Int)
    prec = SD.landscape.environment["precipitation"][:, :, t]
    return heatmap(prec; title="Precipitation at Timestep $t", c=:viridis, yflip=true)
end

"""
    image_restrictions(SD::Simulation_Data, t::Int)

plots the restrictions of a landscape for a given timestep t
"""
function image_restrictions(SD::Simulation_Data, t::Int)
    restr = SD.landscape.restrictions[:, :, t]
    return heatmap(restr; title="Restrictions at Timestep $t", c=:grays, yflip=true)
end

"""
    abundance_gif(SD::Simulation_Data, frames=2)

creates a gif for the abundance of a species in a landscape for all timesteps
"""
function abundance_gif(SD::Simulation_Data, frames=2)
    t = size(SD.species[1].abundances, 3)
    max_ab = maximum(skipmissing(SD.species[1].abundances))
    anim = @animate for i in 1:t
        heatmap(
            SD.species[1].abundances[:, :, i];
            title="Species Abundance at Timestep $i",
            c=:YlGnBu,
            clims=(0, max_ab),
            yflip=true,
        )
    end
    return gif(anim, "Abundances.gif"; fps=frames)
end

"""
    suitability_gif(SD::Simulation_Data, frames=2)

creates a gif for the habitat suitability of a landscape for all timesteps
"""
function suitability_gif(SD::Simulation_Data, frames=2)
    t = size(SD.species[1].habitat, 3)
    anim = @animate for i in 1:t
        heatmap(
            SD.species[1].habitat[:, :, i];
            title="Habitat Suitability at Timestep $i",
            c=:YlOrBr,
            clims=(0, 1),
            yflip=true,
        )
    end
    return gif(anim, "Suitability.gif"; fps=frames)
end

function plot_all(SD::Simulation_Data, t::Int)
    l = @layout [a b; _ c]
    temp = SD.landscape.environment["temperature"][:, :, t]
    env_t = heatmap(temp)#; title="Temperature at Timestep $t", c=:plasma, yflip=true)
    prec = SD.landscape.environment["precipitation"][:, :, t]
    env_p = heatmap(prec)#; title="Precipitation at Timestep $t", c=:viridis, yflip=true)
    x_prec = collect(range(0; stop=3000, length=1000))
    y_prec = get_habitat_suit(
        SD.species[1].traits.env_preferences["precipitation"].upper_limit,
        SD.species[1].traits.env_preferences["precipitation"].optimum,
        SD.species[1].traits.env_preferences["precipitation"].lower_limit,
        x_prec,
    )
    tol_p = plot(x_prec, y_prec)
    x_temp = collect(range(200; stop=400, length=1000))
    y_temp = get_habitat_suit(
        SD.species[1].traits.env_preferences["temperature"].upper_limit,
        SD.species[1].traits.env_preferences["temperature"].optimum,
        SD.species[1].traits.env_preferences["temperature"].lower_limit,
        x_temp,
    )
    tol_t = plot(x_temp, y_temp)
    input_plot = plot(tol_t, tol_p, env_t, env_p; layout=4)
    suitability = SD.species[1].habitat[:, :, t]
    output_suit = heatmap(suitability)#; title="Habitat Suitability at Timestep $t", c=:YlOrBr, yflip=true)
    abundance = SD.species[1].abundances[:, :, t]
    output_abund = heatmap(abundance)#; title="Species Abundance at Timestep $t", c=:YlGnBu, yflip=true)
    allplot = plot(input_plot, output_suit, output_abund; layout=l)
    return allplot
end

using CairoMakie
function plot_all_cairo(SD::Simulation_Data, t::Int)
    temp = SD.landscape.environment["temperature"][:, :, t]
    prec = SD.landscape.environment["precipitation"][:, :, t]
    suitability = SD.species[1].habitat[:, :, t]
    abundance = SD.species[1].abundances[:, :, t]
    x_prec = collect(range(0; stop=3000, length=1000)) #TODO find better start-stop
    y_prec = get_habitat_suit(
        SD.species[1].traits.env_preferences["precipitation"].upper_limit,
        SD.species[1].traits.env_preferences["precipitation"].optimum,
        SD.species[1].traits.env_preferences["precipitation"].lower_limit,
        x_prec,
    )
    x_temp = collect(range(200; stop=400, length=1000)) #TODO find better start-stop
    y_temp = get_habitat_suit(
        SD.species[1].traits.env_preferences["temperature"].upper_limit,
        SD.species[1].traits.env_preferences["temperature"].optimum,
        SD.species[1].traits.env_preferences["temperature"].lower_limit,
        x_temp,
    )

    f = Figure(; resolution=(1000, 700), figure_padding=1)

    box_size_l = 10

    box_size_r = 6

    plot_size = 4

    f_left = f[1:2, 1:2] = GridLayout()
    f_right = f[1:2, 3] = GridLayout()

    box_left = Box(
        f_left[1:(box_size_l), 2:(box_size_l)];
        color=(:gray80, 0.5),
        alignmode=Outside(),
        strokecolor=:black,
    )

    box_right = Box(
        f_right[1:box_size_l, 1:box_size_r];
        color=(:white, 0.5),
        alignmode=Outside(),
        strokecolor=:black,
    )

    title_left = Label(
        f_left[2, 2:(box_size_l - 1), Top()],
        "Input parameters";
        fontsize=26,
        font=:bold,
        padding=(0, 50, 50, 0),
    )

    title_right = Label(
        f_right[2, 2:(box_size_r - 1), Top()],
        "Output";
        fontsize=26,
        font=:bold,
        padding=(0, 50, 50, 0),
    )

    ax1 = Axis(f_left[2:(1 + plot_size), 2:(1 + plot_size)]; 
    title="Temperature tolerance")
    tol_t = CairoMakie.lines!(ax1, x_temp, y_temp)

    ax2 = Axis(
        f_left[2:(1 + plot_size), (2 + plot_size):(1 + plot_size * 2)];
        title="precipitation tolerance",
    )
    tol_p = CairoMakie.lines!(ax2, x_prec, y_prec)

    ax3 = Axis(
        f_left[(2 + plot_size):(1 + plot_size * 2), 2:(1 + plot_size)]; 
        title="temperature"
    )
    env_t = CairoMakie.heatmap!(ax3, temp)

    ax4 = Axis(
        f_left[(2 + plot_size):(1 + plot_size * 2), (2 + plot_size):(1 + plot_size * 2)];
        title="precipitation",
    )
    env_t = CairoMakie.heatmap!(ax4, prec)

    ax5 = Axis(f_right[2:(1 + plot_size), 2:(1 + plot_size)]; title="habitat suitability")
    CairoMakie.heatmap!(ax5, suitability)

    ax6 = Axis(
        f_right[(2 + plot_size):(1 + plot_size * 2), 2:(1 + plot_size)]; title="abundance"
    )
    CairoMakie.heatmap!(ax6, abundance)

    return f
end
