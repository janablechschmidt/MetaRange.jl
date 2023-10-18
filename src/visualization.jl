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
    l = @layout [a b ; _ c]
    temp = SD.landscape.environment["temperature"][:, :, t]
    env_t = heatmap(temp)#; title="Temperature at Timestep $t", c=:plasma, yflip=true)
    prec = SD.landscape.environment["precipitation"][:, :, t]
    env_p = heatmap(prec)#; title="Precipitation at Timestep $t", c=:viridis, yflip=true)
    x_prec = collect(range(0, stop = 3000, length = 1000))
    y_prec = get_habitat_suit(SD.species[1].traits.env_preferences["precipitation"].upper_limit,
        SD.species[1].traits.env_preferences["precipitation"].optimum,
        SD.species[1].traits.env_preferences["precipitation"].lower_limit,
        x_prec)
    tol_p = plot(x_prec, y_prec)
    x_temp = collect(range(200, stop = 400, length = 1000))
    y_temp = get_habitat_suit(SD.species[1].traits.env_preferences["temperature"].upper_limit,
        SD.species[1].traits.env_preferences["temperature"].optimum,
        SD.species[1].traits.env_preferences["temperature"].lower_limit,
        x_temp)
    tol_t = plot(x_temp, y_temp)
    input_plot = plot(tol_t, tol_p, env_t, env_p, layout = 4)
    suitability = SD.species[1].habitat[:, :, t]
    output_suit = heatmap(suitability)#; title="Habitat Suitability at Timestep $t", c=:YlOrBr, yflip=true)
    abundance = SD.species[1].abundances[:, :, t]
    output_abund = heatmap(abundance)#; title="Species Abundance at Timestep $t", c=:YlGnBu, yflip=true)
    allplot = plot(input_plot, output_suit, output_abund, layout = l)
    return allplot
end