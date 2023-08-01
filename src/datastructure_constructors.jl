## functions that construct the respective struct datatypes based on a dict input

function get_Simulation_Parameters(config::Dict)
  return Simulation_Parameters(
    config["experiment_name"],
    config["config_dir"],
    config["output_dir"],
    config["species_dir"],
    config["environment_dir"],
    config["input_backup"],
    config["env_attribute_files"],
    config["env_restriction_files"],
    config["env_attribute_mode"],
    config["env_restriction_mode"],
    config["attribute_restriction_blending"],
    config["timesteps"],
    config["randomseed"],
    config["reproduction_model"],
    config["use_metabolic_theory"],
    config["use_stoch_allee"],
    config["use_stoch_carry"],
    config["use_stoch_num"],
    config["initialize_cells"],
    config["ls_cell_biomass_cap"]
    )
end

function get_Traits(species::Dict)
  return Traits(
    species["mass"],
    species["sd_mass"],

    species["growrate"],
    species["sd_growrate"],
    species["param_const_growrate"],

    #species["prob_dispersal"],
    species["max_dispersal_dist"],
    species["max_dispersal_buffer"],
    species["mean_dispersal_dist"],

    species["allee"],
    species["sd_allee"],
    species["param_const_allee"],

    species["bevmort"],
    species["sd_bevmort"],
    species["param_const_bevmort"],

    species["carry"],
    species["sd_carry"],
    species["param_const_carry"],

    species["env_preferences"],

    species["habitat_cutoff_suitability"]
    )
end

function get_Env_Preferences(species::Dict, key::String)
  return Env_Preferences(
    species["upper_limit_$key"],
    species["lower_limit_$key"],
    species["optimum_$key"],
    )
end

## Each parameter is initialized as an empty matrix eqivalent to the landsape's size
function get_Simulation_Variables()
  return Simulation_Variables(
    Array{Float64}(undef, 0, 0), # habitat
    Array{Bool}(undef, 0, 0), # is_habitat
    Array{Float64}(undef, 0, 0), # future_habitat
    Array{Bool}(undef, 0, 0), # future_is_habitat
    Array{Float64}(undef, 0, 0), # biomass
    Array{Float64}(undef, 0, 0), # growrate
    Array{Float64}(undef, 0, 0), # carry
    Array{Float64}(undef, 0, 0), # allee
    Array{Float64}(undef, 0, 0), # bevmort
    Vector{CartesianIndex{2}}(undef, 0), # occurrences
    Array{Float64}(undef, 0, 0) # offspring
    )
end
