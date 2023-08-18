# The place where shared functions of eco_loop and eco_loop_optim live to decrease code
# duplication between them!

##Setup functions

"""
    GetDispersalSurvival(use_stoch_Num::Bool)

TBW
"""
function GetDispersalSurvival(use_stoch_Num::Bool)
    if use_stoch_Num
        return DispersalSurvivalStoch
    else
        return DispersalSurvivalRound
    end
end

"""
    GetReproductionModel(reproduction_model::String)

TBW
"""
function GetReproductionModel(reproduction_model::String)
    if reproduction_model == "Ricker"
        return ReproductionRicker
    elseif reproduction_model == "Beverton"
        return BV # or BVNoStoch
    elseif reproduction_model == "RickerAllee"
        return ReproductionRickerAllee
    else
        throw(
            ArgumentError(
                reproduction_model* " is not a supported reproduction model. Currently /
                supported are: Ricker, Beverton, and RickerAllee",
            )
        )
    end
end

## Landscape initialization function for biomass_capacity at current timestep

#function init_landscape!(LS::Landscape, biomass_cap::Float64, timestep::Int64)
#  LS.biomass_capacity .= @view(LS.restrictions[:,:,timestep]) .* biomass_cap
#end

## Species functions

# Species parameter initialization function
"""
    init_species_sim_vars!(
    species::Array{Species},
    LS::Landscape,
    parameters::Simulation_Parameters,
    timestep::Int,
)

TBW
"""
function init_species_sim_vars!(
    species::Array{Species},
    LS::Landscape,
    parameters::Simulation_Parameters,
    timestep::Int,
)
    start_time = now()
    for sp in species
        sp.vars.habitat = get_habitat(
            sp.traits.env_preferences,
            LS,
            parameters.env_attribute_mode,
            timestep,
        )
        sp.habitat[:,:,timestep] = get_habitat(
            sp.traits.env_preferences,
            LS,
            parameters.env_attribute_mode,
            timestep,
        )
        sp.vars.is_habitat = get_is_habitat(
            sp.vars.habitat,
            sp.traits.habitat_cutoff_suitability,
        )
        sp.vars.future_habitat = get_habitat(
            sp.traits.env_preferences,
            LS,parameters.env_attribute_mode,
            timestep+1,
        )
        sp.vars.future_is_habitat = get_is_habitat(
            sp.vars.future_habitat,
            sp.traits.habitat_cutoff_suitability,
        )
        sp.vars.biomass = get_biomass(
            sp.traits.mass,
            sp.traits.sd_mass,
            LS.ylength,
            LS.xlength,
        )
        sp.vars.growrate = get_pop_var(
            sp.traits.growrate,
            sp.traits.sd_growrate,
            exp_growrate,
            sp.traits.param_const_growrate,
            sp.traits,
            LS,
            sp.vars.biomass,
            parameters.use_metabolic_theory,
            timestep,
            E_growrate,
        )
        sp.vars.carry = get_pop_carry(
            sp.traits,
            LS,
            sp.vars.habitat,
            sp.vars.biomass,
            parameters.use_metabolic_theory,
            timestep,
            E_carry,
        )
        sp.vars.allee = get_pop_var(
            sp.traits.carry,
            sp.traits.sd_carry,
            exp_carry,
            sp.traits.param_const_carry,
            sp.traits,
            LS,
            sp.vars.biomass,
            parameters.use_metabolic_theory,
            timestep,
            E_allee,
        )
        sp.vars.bevmort = get_pop_bevmort(
            sp.traits,
            LS,
            sp.vars.habitat,
            sp.vars.biomass,
            parameters.use_metabolic_theory,
            timestep,
            E_bevmort,
        )
        sp.vars.occurrences = findall(
            (sp.abundances[:,:,timestep].>0) .& (sp.vars.is_habitat)
        )
    end
    end_time = now()
    @debug(
        "Time needed to simulate the Simulation Variables of all species: ",
        end_time-start_time
    )
end

"""
    get_habitat(
    env_pref::Dict{String, Env_Preferences},
    LS::Landscape,
    attribute_mode::String,
    t::Int
)

Get habitat in current timestep. Return Array{Float64, 2}
"""
function get_habitat(
    env_pref::Dict{String, Env_Preferences},
    LS::Landscape,
    attribute_mode::String,
    t::Int,
)
    env_keys = collect(keys(LS.environment))
    habitability_arr = Array{Float64}(undef, LS.ylength, LS.xlength, length(env_keys))
    for i in 1:length(env_keys)
        conditions = @view(LS.environment[env_keys[i]][:,:,t])
        habitability_arr[:,:,i] = get_habitat_suit(
            env_pref[env_keys[i]].upper_limit,
            env_pref[env_keys[i]].optimum,
            env_pref[env_keys[i]].lower_limit,
            conditions,
        )
    end
    habitability = 1
    if attribute_mode == "minimum"
        habitability = dropdims(minimum(habitability_arr, dims=3), dims=3)
    elseif attribute_mode == "multiplication"
        habitability = habitability_arr[:,:,1]
        for i in 2:length(env_keys)
            habitability = habitability_arr[:,:,i] .* habitability
        end
    else
        throw(MissingException(""))
    end
    restrictions = @view(LS.restrictions[:,:,t])
    return habitability.*restrictions
end

"""
    get_is_habitat(habitat, habitat_cutoff_suitability)

TBW
"""
function get_is_habitat(habitat, habitat_cutoff_suitability)
    return habitat.>habitat_cutoff_suitability
end

"""
    get_biomass(mass, sd_mass, ysize, xsize)

TBW
"""
function get_biomass(mass, sd_mass, ysize, xsize)
    if sd_mass == 0
        biomass = Array{Float64,2}(undef, ysize, xsize)
        fill!(biomass, mass)
    else
      biomass = Randomize(ysize, xsize, mass, sd_mass)
    end
    return biomass
end

"""
    get_pop_var(
    trait::Float64,
    sd_trait::Float64,
    exp_trait::Float64,
    param_const_trait::Union{Float64,Nothing},
    traits::Traits,
    LS::Landscape,
    mass::Array{Float64,2},
    use_metabolic_theory::Bool,
    timestep::Int, E::Float64,
)

TBW
"""
function get_pop_var(
    trait::Float64,
    sd_trait::Float64,
    exp_trait::Float64,
    param_const_trait::Union{Float64,Nothing},
    traits::Traits,
    LS::Landscape,
    mass::Array{Float64,2},
    use_metabolic_theory::Bool,
    timestep::Int, E::Float64,
)
    if use_metabolic_theory
        temperature = @view(LS.environment["temperature"][:,:,timestep])
        pop_param = MetabolicRate(param_const_trait,exp_trait,mass,temperature,E)
    else
        ar = Array{Float64}(undef,LS.ylength,LS.xlength)
        ar .= trait
        # an array full of value InputData[i]. dims y,x
        pop_param = ar
    end
    if sd_trait != 0
        pop_param = Randomize(LS.ylength,LS.xlength,pop_param,sd_trait)
    end
    return pop_param #Matrix{Float64}
end

"""
    get_pop_carry(
    traits::Traits,
    LS::Landscape,
    habitat::Array{Float64,2},
    mass::Array{Float64,2},
    use_metabolic_theory::Bool,
    timestep::Int,
    E::Float64,
)

TBW
"""
function get_pop_carry(
    traits::Traits,
    LS::Landscape,
    habitat::Array{Float64,2},
    mass::Array{Float64,2},
    use_metabolic_theory::Bool,
    timestep::Int,
    E::Float64,
)
    #initialize array to save results of both ways to generate carry
    carry_arr = Matrix{Float64}(undef, LS.ylength, LS.xlength)
    # carry via metabolic_theory
    carry_arr[:,:] = get_pop_var(
        traits.carry,
        traits.sd_carry,
        exp_carry,
        traits.param_const_carry,
        traits,
        LS,
        mass,
        use_metabolic_theory,
        timestep,
        E,
    )
    # is factor 100 needed? was present in old code, commented out
    carry_arr[:,:] = @view(carry_arr[:,:,1]) .* habitat #*100
    # carry via biomass_capacity
    #carry_arr[:,:,2] = mass .\ LS.biomass_capacity
    # take the minimum of either as carry for each cell
    #carry = dropdims(minimum(carry_arr, dims=3), dims=3)
    replace!(carry_arr, NaN=>0)
    carry = trunc.(Int,carry_arr)
    return carry
end

"""
    get_pop_bevmort(
    traits::Traits,
    LS::Landscape,
    habitat::Array{Float64,2},
    mass::Union{Float64,Array{Float64,2}},
    use_metabolic_theory::Bool,
    timestep::Int,
    E::Float64,
)

TBW
"""
function get_pop_bevmort(
    traits::Traits,
    LS::Landscape,
    habitat::Array{Float64,2},
    mass::Union{Float64,Array{Float64,2}},
    use_metabolic_theory::Bool,
    timestep::Int,
    E::Float64,
)
    bevmort = get_pop_var(
        traits.bevmort,
        traits.sd_bevmort,
        exp_bevmort,
        traits.param_const_bevmort,
        traits,
        LS,
        mass,
        use_metabolic_theory,
        timestep,
        E,
    )
    bevmort = bevmort
    for i in eachindex(bevmort)
        bevmort[i] = max(min(bevmort[i], 1), 0)
    end
    return bevmort
end

## Reproduction function
"""
    reproduce(species, reproduction, timestep)

Reproduction function. Takes a vector of species structs, a reproduction function and a
    timestep and calculates the amount of species in the next timestep.
"""
function reproduce!(species::Vector{Species}, Reproduction, timestep::Int)
    for sp in species
        for coordinates in sp.vars.occurrences # spatial loop
            sp.abundances[coordinates,timestep+1] = trunc(
                Int,
                Reproduction(
                    sp.abundances[coordinates,timestep],
                    sp.vars.growrate[coordinates],
                    sp.vars.carry[coordinates],
                    sp.vars.bevmort[coordinates],
                )
            ) # Reproduction
        end
    end
end

"""
    Disperse!(
    species::Vector{Species},
    LS::Landscape,
    groups::NTuple{4, Vector{Chunk}},
    timestep::Int64,
)

Dispersal
"""
function Disperse!(
    species::Vector{Species},
    LS::Landscape,
    groups::NTuple{4, Vector{Chunk}},
    timestep::Int64,
)
    for sp in species
        groupcount = 1
        # initialize offspring
        sp.vars.offspring = zeros(
            LS.ylength+2*sp.traits.max_dispersal_dist,
            LS.xlength+2*sp.traits.max_dispersal_dist,
        )
        # process each group of Chunks after the other concurrently
        for group in groups
            @debug("processing group $groupcount for $(sp.species_name)")
            groupcount = groupcount + 1
            # process the Chunks of each group in parallel
            for chunk in group
                disperse_chunk!(sp, sp.vars.occurrences, sp.vars.offspring, chunk, timestep)
            end
        end
    end
end

## Competition function

#function Competition!(LS::Landscape, species::Vector{Species}, t::Int64)
#  # get total living biomass at each cell
#  total_sp_mass_arr = Array{Float64}(undef, LS.ylength, LS.xlength, length(species))
#  for i in 1:length(species)
#    total_sp_mass_arr[:,:,i] = species[i].vars.biomass .* @view(species[i].abundances[:,:,t+1])
#  end
#  total_biomass = dropdims(sum(total_sp_mass_arr, dims=3), dims=3)
#  # get list of overpopulated cells
#  overpopulated = findall(total_biomass.>LS.biomass_capacity)
#  for coordinates in overpopulated
#    exess_biomass = total_biomass[coordinates] - LS.biomass_capacity[coordinates]
#    habitat_sum = sum([sp.vars.habitat[coordinates] for sp in species])
#    for sp in species
#      # biomass that is allocated for dieoff for species sp
#      sp_exess_biomass = exess_biomass * (sp.vars.habitat[coordinates] / habitat_sum)
#      # convert biomass to individuals
#      comp_dieoff = ceil(sp_exess_biomass / sp.vars.biomass[coordinates])
#      sp.abundances[coordinates, t+1] -= comp_dieoff
#      dieoff[sp.species_name] += comp_dieoff
#    end
#  end
#end

## Survival function

"""
    Survive!(species::Vector{Species}, DispersalSurvival, t::Int64)

TBW
"""
function Survive!(species::Vector{Species}, DispersalSurvival, t::Int64)
    for sp in species
        occurrences = findall(
            (sp.vars.offspring[1:size(sp.abundances,1),1:size(sp.abundances,2)].>0)
        )
        occurrences = hcat(getindex.(occurrences, 1),getindex.(occurrences, 2))
        sp.abundances[:,:,t+1] = DispersalSurvival(
            sp.abundances[:,:,t+1],
            sp.vars.offspring,
            occurrences,
            sp.traits.max_dispersal_dist,
        )
        # Survival to the next timestep depending on habitat quality
        sp.abundances[:,:,t+1] = round.(
            HabitatMortality(sp.abundances[:,:,t+1],sp.vars.future_is_habitat))
        pos = findall(isnan.(sp.habitat[:,:,1]))
        #sp.abundances[pos,t] = NaN
        sp.abundances[pos,t+1] .= missing
    end
end

###### functions for parallelization of dispersal ####

## Parallel Dispesal in a given chunk
"""
    disperse_chunk!(
    species::Species,
    occurrences::Vector{CartesianIndex{2}},
    offspring::Matrix{Float64},
    chunk::Chunk,
    t::Int64,
)

Parallel Dispersal in a given chunk
"""
function disperse_chunk!(
    species::Species,
    occurrences::Vector{CartesianIndex{2}},
    offspring::Matrix{Float64},
    chunk::Chunk,
    t::Int64,
)
    for coordinates in occurrences # spatial loop
        #cache values (mostly a makes the code more readable)
        y, x = coordinates[1], coordinates[2]
        #check if x,y is in a given chunk
        if y >= chunk.y && y < chunk.y+(species.traits.max_dispersal_buffer*2) && x >= chunk.x && x < chunk.x+(species.traits.max_dispersal_buffer*2) #TODO: rewrite this condition
        # Dispersal (Race conditions in SD.Offspring averted by separating landscape into disjunct chunks)
            offspring[
                y:(y+species.traits.max_dispersal_buffer),
                x:(x+species.traits.max_dispersal_buffer),
            ] =
            KernelDispersal!(
                species.abundances[y,x,t+1], #N
                offspring[ #number offspring
                    y:(y+species.traits.max_dispersal_buffer),
                    x:(x+species.traits.max_dispersal_buffer),
                ],
                species.dispersal_kernel, #Kernel
            )
        end
    end
end

"""
    GetDisjunctChunkGroups(
    max_dispersal_buffer::Int64,
    size::Tuple{Int64, Int64, Int64},
)

Calculate the distinct chunk groups
"""
function GetDisjunctChunkGroups(
    max_dispersal_buffer::Int64,
    size::Tuple{Int64, Int64, Int64},
)
    #separate landscape into 4 disjunct chunk groups
    #Each chunk has the size (2*Dispersalbuffer x 2*Dispersalbuffer)
    #This is to ensure that disjunct groups of roughly equal size can be made trivially
    group1, group2, group3, group4 = Chunk[], Chunk[], Chunk[], Chunk[]

    for x in 1:max_dispersal_buffer*2:size[2]
        for y in 1:max_dispersal_buffer*2:size[1]
            if x % (max_dispersal_buffer*4) - 1 == 0
                if y % (max_dispersal_buffer*4) - 1 == 0
                    push!(group1, Chunk(x, y))
                else
                    push!(group2, Chunk(x, y))
                end
            else
                if y % (max_dispersal_buffer*4) - 1 == 0
                    push!(group3, Chunk(x, y))
                else
                    push!(group4, Chunk(x, y))
                end
            end
        end
    end
    #return the group arrays as a tuple for maximum performance
    return (group1, group2, group3, group4)
end
