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
    return heatmap(abundance; title="Species Abundance at Timestep $t", c=:YlGnBu)
end

"""
    image_suitability(SD::Simulation_Data, t::Int)

plots the habitat suitability of a landscape for a given timestep t
"""
function image_suitability(SD::Simulation_Data, t::Int)
    suitability = SD.species[1].habitat[:, :, t]
    return heatmap(suitability; title="Habitat Suitability at Timestep $t", c=:YlOrBr)
end

"""
    image_temperature(SD::Simulation_Data, t::Int)

plots the temperature of a landscape for a given timestep t
"""
function image_temperature(SD::Simulation_Data, t::Int)
    temp = SD.landscape.environment["temperature"][:, :, t]
    return heatmap(temp; title="Temperature at Timestep $t", c=:plasma)
end

"""
    image_precipitation(SD::Simulation_Data, t::Int)

plots the precipitation of a landscape for a given timestep t
"""
function image_precipitation(SD::Simulation_Data, t::Int)
    prec = SD.landscape.environment["precipitation"][:, :, t]
    return heatmap(prec; title="Precipitation at Timestep $t", c=:viridis)
end

"""
    image_restrictions(SD::Simulation_Data, t::Int)

plots the restrictions of a landscape for a given timestep t
"""
function image_restrictions(SD::Simulation_Data, t::Int)
    restr = SD.landscape.restrictions[:, :, t]
    return heatmap(restr; title="Restrictions at Timestep $t", c=:grays)
end

"""
    abundance_gif(SD::Simulation_Data, frames=2)

creates a gif for the abundance of a species in a landscape for all timesteps
"""
function abundance_gif(SD::Simulation_Data, frames=2)
    t = size(SD.species[1].abundances, 3)
    max_ab = maximum(SD.species[1].abundances)
    anim = @animate for i in 1:t
        heatmap(
            SD.species[1].abundances[:, :, i];
            title="Species Abundance at Timestep $i",
            c=:YlGnBu,
            clims=(0, max_ab),
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
        )
    end
    return gif(anim, "Suitability.gif"; fps=frames)
end
