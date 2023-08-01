function read_input(config_path::String)
    check_constants()
    SP = read_sp(config_path)
    LS = read_ls(SP.environment_dir, SP.env_attribute_files, SP.env_restriction_files, SP.timesteps)
    SV = read_species_dir(SP.species_dir, LS, SP)
    init_out_dir(SP)
    return Simulation_Data(SP, LS, SV, Duration(now(),now()))
end

## Returns the Simulation Parameters as a Simulation_Parameters struct
function read_sp(config_path::String)
  config = get_default_simulation_parameters()
  config["config_dir"] = config_path
  input_config = CSV.File(joinpath(config_path, "configuration.csv")) |> Dict{String, Any}

  # Convert datatypes
  parse_fields_numeric!(input_config)
  parse_fields_bool!(input_config)

  # Overwrite default config where applicable
  for key in keys(input_config)
    config[key] = input_config[key]
  end

  # check if dictionaries exist
  check_speciesdir!(config, config_path)
  check_environmentdir!(config, config_path)
  # apply sanity checks and normalize input path format
  sp_sanity_checks!(config)

  # configure dicts for hoding the files containing the environment parameter files
  parse_environment_parameters!(config, input_config)

  # apply randomseed
  Random.seed!(config["randomseed"]) # Julia random
  return get_Simulation_Parameters(config)
end
