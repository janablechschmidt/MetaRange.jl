#####  Simulation function ######

"""
    run_simulation!(SD::Simulation_Data)

Run an ecological simulation.

Take the initialized simulation data SD and run the simulation for the specified number of
timesteps.

# Arguments
- `SD::MetaRange.Simulation_Data`: MetaRange simulation data struct produced by
[`read_input()`](@ref)

# Returns
- `SD::MetaRange.Simulation_Data`: Returns the struct with later timesteps after
    initialisation simulated.

# Examples
```julia-repl
julia> run_simulation!(SD)
```

See also [`read_input()`](@ref), [`Simulation_Data`](@ref MetaRange.Simulation_Data)
"""
function run_simulation!(SD::Simulation_Data)
    simulation_start_time = now()

    DispersalSurvival = GetDispersalSurvival(SD.parameters.use_stoch_num)

    Reproduction = GetReproductionModel(SD.parameters.reproduction_model)

    groups = GetDisjunctChunkGroups(
        SD.species[1].traits.max_dispersal_buffer,
        size(SD.landscape.environment["temperature"]),
    )

    ##### Eco Loop ######
    for t in 1:(SD.parameters.timesteps - 1) # temporal loop
        @info("timestep ", t)

        # initialize the biomass capacity of the landsape
        #init_landscape!(SD.landscape, SD.parameters.ls_cell_biomass_cap, t)

        #Evolution!() ## placeholder for potential expansion of the model to include evolution

        # initialize the species parameter arras for this timestep for each species
        init_species_sim_vars!(SD.species, SD.landscape, SD.parameters, t)

        start_time = now()
        reproduce!(SD.species, Reproduction, t)
        end_time = now()
        @debug("Reproduction time: ", end_time - start_time)
        ## placeholder for potential expansion of the model to include interspecies competition
        #start_time = now()
        #Competition!(SD.landscape, SD.species, t)
        #end_time = now()
        #@debug("Competition time: ", end_time-start_time)

        start_time = now()
        Disperse!(SD.species, SD.landscape, groups, t)
        end_time = now()
        @debug("Dispersal time: ", end_time - start_time)

        ## Dispersal Survival
        start_survival = now()
        Survive!(SD.species, DispersalSurvival, t)
        end_survival = now()
        @debug("Survival time: ", end_survival - start_survival)

        #if sum(SD.species[1].abundances[:,:,t])<1 println("all individuals are dead"); break
        #end

    end
    init_species_sim_vars!(SD.species, SD.landscape, SD.parameters, SD.parameters.timesteps)
    inds = isnan.(SD.species[1].output.habitat)
    SD.species[1].output.carry[inds] .= missing
    simulation_end_time = now()
    @info("elapsed time: ", simulation_end_time - simulation_start_time)
    SD.duration.start_time = simulation_start_time
    return SD.duration.end_time = simulation_end_time
end
