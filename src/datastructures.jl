"""
    Env_Preferences

Struct for saving the environmental preferences of a species.

# Fields
- `upper_limit::Float64`: species parameter
- `lower_limit::Float64`: species parameter
- `optimum::Float64`: species parameter
"""
struct Env_Preferences
    "Species Parameter"
    upper_limit::Float64
    "Species Parameter"
    lower_limit::Float64
    "Species Parameter"
    optimum::Float64
end

"""
    Traits

Traits of a species.

#TODO: Add description in fields
# Fields
- `mass::Float64`:
- `sd_mass::Float64`:
- `growrate::Float64`:
- `sd_growrate::Float64`:
- `param_const_growrate::Union{Float64, Nothing}`:
- `max_dispersal_dist::Int64`:
- `max_dispersal_buffer::Int64`:
- `mean_dispersal_dist::Int64`:
- `allee::Float64`: Allee effect counteracting negative diversity loss in small populations
- `sd_allee::Float64`: Allee effect standard deviation
- `param_const_allee::Union{Float64, Nothing}`:
- `bevmort::Float64`:
- `sd_bevmort::Float64`:
- `param_const_bevmort::Union{Float64, Nothing}`:
- `carry::Float64`:
- `sd_carry::Float64`:
- `param_const_carry::Union{Float64, Nothing}`:
- `env_preferences::Dict{String, Env_Preferences}`:
- `habitat_cutoff_suitability::Float64`:
"""
struct Traits
    "Species Parameter"
    mass::Float64 # Species Parameter
    "Species Parameter standard deviation"
    sd_mass::Float64 # Species Parameter
    "Species Parameter"
    growrate::Float64 # Species Parameter
    "Species Parameter standard deviation"
    sd_growrate::Float64 # Species Parameter std dev
    "Species Parameter"
    param_const_growrate::Union{Float64, Nothing}  # Species Parameter

    #prob_dispersal::Float64 # Species Parameter
    "Species Parameter"
    max_dispersal_dist::Int64 # Species Parameter
    "Species Parameter"
    max_dispersal_buffer::Int64 # not sure if needed at all
    "Species Parameter"
    mean_dispersal_dist::Int64  # Species Parameter

    "Allee effect counteracting negative diversity loss in small populations"
    allee::Float64
    "Allee effect standard deviation"
    sd_allee::Float64
    "Species parameter"
    param_const_allee::Union{Float64, Nothing} # Species Parameter

    "Beverton mortality"
    bevmort::Float64
    "Beverton mortality standard deviation"
    sd_bevmort::Float64
    "Species Parameter"
    param_const_bevmort::Union{Float64, Nothing} # Species Parameter

    "Species Parameter"
    carry::Float64 # Species Parameter
    "Species Parameter standard deviation"
    sd_carry::Float64 # Species Parameter std dev
    "Species Parameter"
    param_const_carry::Union{Float64, Nothing} # Species Parameter

    "Dictionary of environmental preferences"
    env_preferences::Dict{String, Env_Preferences}

    "Species Parameter"
    habitat_cutoff_suitability::Float64 # Species Parameter
end
"""
    Simulation_Variables

Simulation variables used for a species during [Run_Simulation!](@ref)"

# Fields
-`habitat::Array{Float64, 2}`: habitability of landscape cells for a species at current
simulation timestep
-`is_habitat::BitArray{2}`: if landscape cells are habitable for a species at current
simulation timestep
-`future_habitat::Array{Float64}`: TODO
-`future_is_habitat::BitArray{2}`: if landscape cells are habitable for a species at next
simulation timestep
-`biomass::Array{Float64, 2}`: biomass of a species individual at landscape cells
-`growrate::Array{Float64, 2}`: growrate of species at landscape cells
-`carry::Array{Float64, 2}`: carry property of species at landscape cells
-`allee::Array{Float64, 2}`: allee property of species at landscape cells
-`bevmort::Array{Float64, 2}`: Beverton mortaility of species at landscape cells
-`occurrences::Vector{CartesianIndex{2}}`: list of cells where species occurs at current
timestep
-`offspring::Array{Float64, 2}`: offspring of species at current timestep
"""
mutable struct Simulation_Variables
    "habitability of landscape cells for a species at current sim timestep"
    habitat::Array{Float64, 2}
    "if landscape cells are habitable for a species at current sim timestep"
    is_habitat::BitArray{2}
    "if landscape cells are habitable for a species at next sim timestep"
    future_habitat::Array{Float64, 2}
    "if landscape cells are habitable for a species at next sim timestep"
    future_is_habitat::BitArray{2}
    "biomass of a species individual at landscape cells"
    biomass::Array{Float64, 2}
    "growrate of species at landscape cells"
    growrate::Array{Float64, 2}
    "carry property of species at landscape cells"
    carry::Array{Float64, 2}
    "allee property of species at landscape cells"
    allee::Array{Float64, 2}
    "Beverton mortaility of species at landscape cells"
    bevmort::Array{Float64, 2}
    "list of cells where species occurs at current timestep"
    occurrences::Vector{CartesianIndex{2}}
    "offspring of species at current timestep"
    offspring::Array{Float64, 2}
end

## Struct for saving all data related to a species
"""
    Species

Saving all data related to a species.

# Fields
-`species_name::String`: name of the species
-`traits::Traits`: a (Traits)[@ref] struct for the species
-`abundances::Array{Union{Int64, Missing}, 3}`: amount of individuals of this species in
each timestep
-`habitat::Array{Float64, 3}`: habitat suitability in each timestep
-`dispersal_kernel::Matrix{Float64}`:#TODO
-`vars::Simulation_Variables`:#TODO
"""
struct Species
    species_name::String
    traits::Traits
    abundances::Array{Union{Int64, Missing}, 3} #amount of species individuals
    habitat::Array{Float64, 3} # habitat suitability in each timestep
    dispersal_kernel::Matrix{Float64}
    vars::Simulation_Variables
end

## Struct for saving all data related to the landscape/environment

struct Landscape
    xlength::Int64 # equivalent to size[2] of any Array in this struct
    ylength::Int64 # equivalent to size[1] of any Array in this struct
    environment::Dict{String, Array{Float64, 3}} # contains all environment attributes, addressable by name
    restrictions::Array{Float64, 3}
    #biomass_capacity::Matrix{Float64} # contains biomass_capacity of current timestep in simulation
end

## Struct for saving simulation parameters

struct Simulation_Parameters
    experiment_name::String # Simulation Parameter
    config_dir::String # Location of the config_file
    output_dir::String # Simulation Parameter, filepath of save location
    species_dir::String # directory of species definitions used in the simulation
    environment_dir::String # directory of environment definitions
    input_backup::Bool # Toggle if input should be included in the output folder
    env_attribute_files::Dict{String, String}
    env_restriction_files::Dict{String, String}
    env_attribute_mode::String
    env_restriction_mode::String
    attribute_restriction_blending::String
    timesteps::Int64 # Simulation Parameter
    randomseed::Int64
    reproduction_model::String # Simulation Parameter
    use_metabolic_theory::Bool # Simulation Parameter
    use_stoch_allee::Bool # Simulation Parameter (Allee Effect: min size of sustainable population)
    use_stoch_carry::Bool # Simulation Parameter (Max nubr of individuals pro cell )
    use_stoch_num::Bool # Simulation Parameter TODO: Stochastic Survival see R code
    initialize_cells::String # Simulation Parameter
    #ls_cell_biomass_cap::Float64 # saves maximum biomass capacity in a cell
end

## Struct for saving the duration of the entire simulation

mutable struct Duration
    start_time::DateTime
    end_time::DateTime
end

"""
    Simulation_Data

Struct for saving all data related to the simulation

# Fields
- `parameters::Simulation_Parameters`: simulation parameters of the experiment
- `landscape::Landscape`: landscape of the experiment
- `species::Vector{Species}`: a vector of all the species in the experiment
- `duration::Duration`: saves the duration the experiment took to compute
"""
struct Simulation_Data
    parameters::Simulation_Parameters
    landscape::Landscape
    species::Vector{Species}
    duration::Duration # Saves the duration of time the simulation took to compute
end

"""
    Chunk


Struct for saving chunk coordinates

# Fields
-`x::Int`
-`y::Int`
"""
struct Chunk
    x::Int
    y::Int
end
