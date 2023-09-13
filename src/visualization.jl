"""
plot_abundances(SD::Simulation_Data)
plots the total abundances of a species over time
"""
function plot_abundances(SD::Simulation_Data)
    total_abundance = vec(sum(sum(SD.species[1].abundances, dims=1),dims=2))
    x = 1:length(total_abundance)
    carry = fill(sum(SD.species[1].vars.carry.*SD.species[1].vars.habitat),length(total_abundance))
    plot(x, [total_abundance carry], title = "Species Abundance over Time", label = ["Abundance" "Carrying Capacity"])
    xlabel!("timestep")
    ylabel!("total abundance")
    ylims!(0,maximum(total_abundance))
end

"""
image_abundances(SD::Simulation_Data, t::Int)
plots the species abundance in the landscape for a given timestep t
"""
function image_abundances(SD::Simulation_Data, t::Int)
    abundance = SD.species[1].abundances[:,:,t]
    heatmap(abundance)
end

"""
image_suitability(SD::Simulation_Data, t::Int)
plots the habitat suitability of a landscape for a given timestep t
"""
function image_suitability(SD::Simulation_Data, t::Int)
    suitability = SD.species[1].habitat[:,:,t]
    heatmap(suitability)
end