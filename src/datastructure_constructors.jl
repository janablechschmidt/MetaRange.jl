## functions that construct the respective struct datatypes based on a dict input

"""
    get_Simulation_Parameters(config::Dict)

Returns a Simulation_Parameters object constructed from the configuration Dictionary.
"""
function get_Simulation_Parameters(config::Dict)
    return Simulation_Parameters(
        config["experiment_name"],
        config["config_dir"],
        config["config_file"],
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
        #config["use_stoch_allee"],
        #config["use_stoch_carry"],
        config["use_stoch_num"],
        config["initialize_cells"],
        #config["ls_cell_biomass_cap"]
    )
end

"""
    get_Traits(species::Dict)

Extracts species traits from the configuration dictionary and returns a Trait object.
"""
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
        species["habitat_cutoff_suitability"],
    )
end

"""
    get_Env_Preferences(species::Dict, key::String)

Returns the environmental preference for the supplied trait in `key` with limits and optimum
as an Env_Preferences object.
"""
function get_Env_Preferences(species::Dict, key::String)
    return Env_Preferences(
        species["upper_limit_$key"], species["lower_limit_$key"], species["optimum_$key"]
    )
end

## Each parameter is initialized as an empty matrix eqivalent to the landsape's size
"""
    get_Simulation_Variables()

Initializes an empty Simulation_Variables object. Each parameter is defined with an empty
matrix eqivalent to the landscape's size.
"""
function get_Simulation_Variables()
    return Simulation_Variables(
        Array{Float64}(undef, 0, 0), # habitat
        BitArray(undef, 0, 0), # is_habitat
        Array{Float64}(undef, 0, 0), # future_habitat
        BitArray(undef, 0, 0), # future_is_habitat
        Array{Float64}(undef, 0, 0), # biomass
        Array{Float64}(undef, 0, 0), # growrate
        Array{Float64}(undef, 0, 0), # carry
        Array{Float64}(undef, 0, 0), # allee
        Array{Float64}(undef, 0, 0), # bevmort
        Vector{CartesianIndex{2}}(undef, 0), # occurrences
        Array{Float64}(undef, 0, 0), # offspring
    )
end
