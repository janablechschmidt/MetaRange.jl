"""
    read_input(path::String)

Reads in the .config and associated files in the folder and returns a Simulation_Data
struct.
"""
function read_input(config_path::String)
    check_constants()
    SP = read_sp(config_path)
    LS = read_ls(
        SP.environment_dir,
        SP.env_attribute_files,
        SP.env_restriction_files,
        SP.timesteps)
    SV = read_species_dir(SP.species_dir, LS, SP)
    init_out_dir(SP)
    SD = Simulation_Data(SP, LS, SV, Duration(now(),now()))
    return SD
end

"""
    read_sp(path)

Returns simulation parameters in "path/configuration.csv" as a Simulation_Parameters struct.
"""
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


#TODO: Unload function and modularize
#This probably needs to be a loading function with sanity checks and other initialisation
#functions that calculate missing or wrong values
"""
    read_species_dir(species_dir::String, LS::Landscape, SP::Simulation_Parameters)

Read species directory, calculate properties and parameters if not provided and return as a
vector of Species objects.
"""
function read_species_dir(species_dir::String, LS::Landscape, SP::Simulation_Parameters)
    input_species = readdir(species_dir)
    species_vec = Species[]
    # read each species definition file found in the species directory and add each read
    # species to the species vector
    for species_def in input_species
        species = CSV.File(joinpath(species_dir, species_def)) |> Dict{String, Any}
        # convert all Float and Integer arguments to their respective Julia types
        parse_species_datatypes!(species)
        # calculate properties
        species["max_dispersal_buffer"] = species["max_dispersal_dist"]*2

        # calculate environment properties
        env_preferences = Dict{String, Env_Preferences}()
        for key in keys(LS.environment)
            if key == "temperature"
                if species["lower_limit_temperature"] < 60
                    species["lower_limit_temperature"] += 273.15
                    species["upper_limit_temperature"] += 273.15
                    species["optimum_temperature"] += 273.15
            end
        end
        #species["optimum_$key"] = mean([species["lower_limit_$key"],species["upper_limit_$key"]])
        #species["tolerance_$key"] = ComputeTolerance(species["response_$key"],
          #species["lower_limit_$key"],species["upper_limit_$key"])
        env_preferences[key] = get_Env_Preferences(species, key)
    end
        species["env_preferences"] = env_preferences
        # calibrate pop params if they weren't provided
        pop_param = ["growrate","carry","allee","bevmort"]
        exp = Dict(
            "growrate" => exp_growrate,
            "carry" => exp_carry,
            "allee" => exp_allee,
            "bevmort" => exp_bevmort,
        )
        en = Dict(
            "growrate" => E_growrate,
            "carry" => E_carry,
            "allee" => E_allee,
            "bevmort" => E_bevmort,
        )
        for param in pop_param
            if "param_const_$param" ∉ keys(species)
                # Determined in GetPopParam function later, dependent on envlolving traits!
                species["param_const_$param"] = ParamCalibration(
                    species[param],
                    exp[param],
                    species["mass"],
                    species["optimum_temperature"],
                    en[param],
                )
            end
        end

        # TODO Sanity Checks
        # param_const_growrate, param_const_allee, param_const_bevmort and param_const_carry
        # should not be 0 as they produce 0s when using metabolic_theory in function
        # GetPopParam() function which in turn produce NAN values when the corresponding sd
        # parameter is not 0 in the randomize() function bevmort can only be in range [0,1]
        # Build Traits struct
        traits = get_Traits(species)
        # calculate habitat
        habitat = zeros(Float64, LS.ylength, LS.xlength, SP.timesteps) # x y z
        habitat[:,:,1] = get_habitat(traits.env_preferences,LS,SP.env_attribute_mode,1)
        # initialize abundances
        abundances = InitializeAbundances(SP,habitat[:,:,1],traits.carry)
        dispersal_kernel = DispersalNegExpKernel(
            traits.max_dispersal_dist,
            traits.mean_dispersal_dist,
        )
        #total_abundance = Vector{Union{Nothing,Int64}}(undef,SP.timesteps)
        push!(
            species_vec,
            Species(species["species_name"],
            traits,
            abundances,
            habitat,
            dispersal_kernel,
            get_Simulation_Variables()),
        )
    end
    return species_vec
end
