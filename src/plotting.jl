using Plots
plot1 = heatmap(reverse(SD.species[1].abundances[:,:,1],dims=1), title = "Abundance at start")
plot2 = heatmap(reverse(SD.species[1].abundances[:,:,SD.parameters.timesteps],dims=1), title = "Abundance at end")
plot(plot1,plot2, layout = (1,2))

plot4 = heatmap(reverse(SD.landscape.environment["temperature"][:,:,1],dims=1), title="Temperature")
plot5 = heatmap(reverse(SD.landscape.environment["precipitation"][:,:,1],dims=1), title="Precipitation")
plot(plot4, plot5, layout = (1,2))

plot5 = heatmap(reverse(SD.species[1].vars.habitat,dims=1), title="Habitat suitability")
plot(plot5)
plot6 = heatmap(reverse(SD.species[1].habitat[:,:,1],dims=1), title="Habitat suitability at start")
plot7 = heatmap(reverse(SD.species[1].habitat[:,:,(SD.parameters.timesteps-1)],dims=1), title="Habitat suitability at end")

### ok now let's try CairoMakie shall we?
using CairoMakie

heatmap(rotr90(SD.species[1].abundances[:,:,10]))
heatmap(rotr90(SD.species[1].habitat[:,:,10]))