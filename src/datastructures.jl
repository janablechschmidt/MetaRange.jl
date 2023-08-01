## Struct for saving the environment preferences of a species
struct Env_Preferences
    upper_limit::Float64 # Species Parameter
    lower_limit::Float64 # Species Parameter
    optimum::Float64 # Species Parameter
end

## Struct for saving species traits

struct Traits
    mass::Float64 # Species Parameter
    sd_mass::Float64 # Species Parameter

    growrate::Float64 # Species Parameter
    sd_growrate::Float64 # Species Parameter std dev
    param_const_growrate::Union{Float64,Nothing}  # Species Parameter

    #prob_dispersal::Float64 # Species Parameter
    max_dispersal_dist::Int64 # Species Parameter
    max_dispersal_buffer::Int64 # Species Parameter, not sure if needed at all
    mean_dispersal_dist::Int64  # Species Parameter

    allee::Float64 # Species Parameter allee effect counteracting negative diversity loss in small populations
    sd_allee::Float64 # Species Parameter
    param_const_allee::Union{Float64,Nothing} # Species Parameter

    bevmort::Float64
    sd_bevmort::Float64
    param_const_bevmort::Union{Float64,Nothing} # Species Parameter

    carry::Float64 # Species Parameter
    sd_carry::Float64 # Species Parameter std dev
    param_const_carry::Union{Float64,Nothing} # Species Parameter

    env_preferences::Dict{String, Env_Preferences}

    habitat_cutoff_suitability::Float64 # Species Parameter
end

## Struct for saving Simulation Variables of species used during a simulation timestep

mutable struct Simulation_Variables
    habitat::Array{Float64,2} # habitability of landsape cells for a species at current sim timestep
    is_habitat::BitArray{2} # if landsape cells are habitable for a species at current sim timestep
    future_habitat::Array{Float64,2} # if landsape cells are habitable for a species at next sim timestep
    future_is_habitat::BitArray{2} # if landsape cells are habitable for a species at next sim timestep
    biomass::Array{Float64,2} # biomass of a species individual at landsape cells
    growrate::Array{Float64,2} # growrate of species at landsape cells
    carry::Array{Float64,2} # carry propery of species at landsape cells
    allee::Array{Float64,2} # allee propery of species at landsape cells
    bevmort::Array{Float64,2} # bevmort propery of species at landsape cells
    occurrences::Vector{CartesianIndex{2}} # list of cells where species occures at current timestep
    offspring::Array{Float64,2} # offspring of species at current timestep
end

## Struct for saving all data related to a species

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
    biomass_capacity::Matrix{Float64} # contains biomass_capacity of current timestep in simulation
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
    ls_cell_biomass_cap::Float64 # saves maximum biomass capacity in a cell
end

## Struct for saving the duration of the entire simulation

mutable struct Duration
    start_time::DateTime
    end_time::DateTime
end

## Struct for saving all data related to the simulation

struct Simulation_Data
    parameters::Simulation_Parameters
    landscape::Landscape
    species::Vector{Species}
    duration::Duration # Saves the duration of time the simulation took to compute
end

## Struct for saving chunk coordinates

struct Chunk
    x::Int
    y::Int
end
