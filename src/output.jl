"""
    plot_abundances(SD::Simulation_Data)

plots the total abundances of a species over time
"""
function plot_abundances(SD::Simulation_Data)
    total_abundance = vec(sum(sum(SD.species[1].output.abundances; dims=1); dims=2))
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
    abundance = SD.species[1].output.abundances[:, :, t]
    return heatmap(
        abundance; title="Species Abundance at Timestep $t", c=:YlGnBu, yflip=true
    )
end

"""
    image_suitability(SD::Simulation_Data, t::Int)

plots the habitat suitability of a landscape for a given timestep t
"""
function image_suitability(SD::Simulation_Data, t::Int)
    suitability = SD.species[1].output.habitat[:, :, t]
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
    t = size(SD.species[1].output.abundances, 3)
    max_ab = maximum(skipmissing(SD.species[1].output.abundances))
    anim = @animate for i in 1:t
        heatmap(
            SD.species[1].output.abundances[:, :, i];
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
    t = size(SD.species[1].output.habitat, 3)
    anim = @animate for i in 1:t
        heatmap(
            SD.species[1].output.habitat[:, :, i];
            title="Habitat Suitability at Timestep $i",
            c=:YlOrBr,
            clims=(0, 1),
            yflip=true,
        )
    end
    return gif(anim, "Suitability.gif"; fps=frames)
end

"""
    carry_gif(SD::Simulation_Data, frames=2)

creates a gif for the carrying capacity of a landscape for all timesteps
"""
function carry_gif(SD::Simulation_Data, frames=2)
    t = size(SD.species[1].output.carry, 3)
    anim = @animate for i in 1:t
        heatmap(
            SD.species[1].output.carry[:, :, i];
            title="Carrying Capacity at Timestep $i",
            c=:YlOrBr,
            clims=(0, maximum(SD.species[1].output.carry)),
            yflip=true,
        )
    end
    return gif(anim, "Carry.gif"; fps=frames)
end

"""
    reproduction_gif(SD::Simulation_Data, frames=2)

creates a gif for the reproduction rate of a species in landscape for all timesteps
"""
function reproduction_gif(SD::Simulation_Data, frames=2)
    t = size(SD.species[1].output.growrate, 3)
    anim = @animate for i in 1:t
        heatmap(
            SD.species[1].output.growrate[:, :, i];
            title="Reproduction Rate at Timestep $i",
            c=:YlOrBr,
            clims=(0, maximum(SD.species[1].output.growrate)),
            yflip=true,
        )
    end
    return gif(anim, "Reproduction.gif"; fps=frames)
end

"""
    mortality_gif(SD::Simulation_Data, frames=2)

creates a gif for the mortality rate of a species in a landscape for all timesteps
"""
function mortality_gif(SD::Simulation_Data, frames=2)
    t = size(SD.species[1].output.bevmort, 3)
    anim = @animate for i in 1:t
        heatmap(
            SD.species[1].output.bevmort[:, :, i];
            title="Mortality Rate at Timestep $i",
            c=:YlOrBr,
            clims=(0, maximum(SD.species[1].output.bevmort)),
            yflip=true,
        )
    end
    return gif(anim, "Mortality.gif"; fps=frames)
end

"""
    save_all(SD::Simulation_Data)

saves all output variables - reproduction, mortality rate, carrying capacity, habitat suitability, abundance - in a CSV file.
The format is as follows: t, x, y, value, parameter
"""
function save_all(SD::Simulation_Data)
    abundance = vec(SD.species[1].output.abundances)
    habitat = vec(SD.species[1].output.habitat)
    reproduction = vec(SD.species[1].output.growrate)
    carry = vec(SD.species[1].output.carry)
    bevmort = vec(SD.species[1].output.bevmort)
    inds = vec(CartesianIndices(SD.species[1].output.abundances))
    t = getindex.(inds, 3)
    x = getindex.(inds,2)
    y = getindex.(inds,1)
    abundance_out = hcat(t, x, y, abundance, repeat(["abundance"], length(t)))
    reproduction_out = hcat(t, x, y, reproduction, repeat(["reproduction"], length(t)))
    habitat_out = hcat(t, x, y, habitat, repeat(["habitat"], length(t)))
    carry_out = hcat(t, x, y, carry, repeat(["carry"], length(t)))
    bevmort_out = hcat(t, x, y, bevmort, repeat(["bevmort"], length(t)))
    out = vcat(abundance_out, habitat_out, reproduction_out, carry_out, bevmort_out)
    make_out_dir(SD.parameters.output_dir)
    writedlm(joinpath(SD.parameters.output_dir, "output.csv"), out, ',')
end
