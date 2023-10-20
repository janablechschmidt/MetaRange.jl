"""
    read_input(path::String)

Reads in the configuration and associated files in the folder and returns a Simulation_Data
struct.
"""
function read_input(config_path::String)
    check_constants()
    SP = read_sp(config_path)
    LS = read_ls(
        SP.environment_dir, SP.env_attribute_files, SP.env_restriction_files, SP.timesteps
    )
    SV = read_species_dir(SP.species_dir, LS, SP)
    init_out_dir(SP)
    SD = Simulation_Data(SP, LS, SV, Duration(now(), now()))
    return SD
end

"""
    read_sp(path)

Returns simulation parameters in "path/configuration.csv" as a Simulation_Parameters struct.
"""
## Returns the Simulation Parameters as a Simulation_Parameters struct
function read_sp(config_path::String)
    config = get_default_simulation_parameters()
    config["config_file"] = normpath(abspath(config_path))
    config["config_dir"] = normpath(abspath(dirname(config_path)))
    input_config = Dict{String,Any}(CSV.File(config["config_file"]))

    # Convert datatypes
    parse_fields_numeric!(input_config)
    parse_fields_bool!(input_config)

    # Overwrite default config where applicable
    for key in keys(input_config)
        config[key] = input_config[key]
    end

    # get the full path to the provided directories
    config["species_dir"] = get_species_dir(config)
    config["environment_dir"] = get_environment_dir(config)
    config["output_dir"] = get_out_dir(config)

    # apply sanity checks
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
        species = Dict{String,Any}(CSV.File(joinpath(species_dir, species_def)))
        # convert all Float and Integer arguments to their respective Julia types
        parse_species_datatypes!(species)
        # calculate properties
        species["max_dispersal_buffer"] = species["max_dispersal_dist"] * 2

        # calculate environment properties
        env_preferences = Dict{String,Env_Preferences}()
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
        pop_param = ["growrate", "carry", "allee", "bevmort"]
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
        # parameter is not 0 in the randomize!() function bevmort can only be in range [0,1]
        # Build Traits struct
        traits = get_Traits(species)
        # calculate habitat
        habitat = zeros(Float64, LS.ylength, LS.xlength, SP.timesteps) # x y z
        habitat[:, :, 1] = get_habitat(traits.env_preferences, LS, SP.env_attribute_mode, 1)
        # initialize abundances
        abundances = InitializeAbundances(SP, habitat[:, :, 1], traits.carry)
        dispersal_kernel = DispersalNegExpKernel(
            traits.max_dispersal_dist, traits.mean_dispersal_dist
        )
        carry_out = zeros(Float64, LS.ylength, LS.xlength, SP.timesteps)
        growrate_out = zeros(Float64, LS.ylength, LS.xlength, SP.timesteps)
        bevmort_out = zeros(Float64, LS.ylength, LS.xlength, SP.timesteps)
        output = Output(abundances, habitat, carry_out, growrate_out, bevmort_out)
        #total_abundance = Vector{Union{Nothing,Int64}}(undef,SP.timesteps)
        push!(
            species_vec,
            Species(
                species["species_name"],
                traits,
                output,
                dispersal_kernel,
                get_Simulation_Variables(),
            ),
        )
    end
    return species_vec
end

"""
    get_environment_dir(config::Simulation_Parameters)

Returns full path to environment folder or returns config_dir/environment when no path to
the species folder is provided.
"""
function get_environment_dir(config::Dict{String,Any})
    if isnothing(config["environment_dir"])
        env_dir = normpath(joinpath(config["config_dir"], "environment/"))
    else
        env_dir = normpath(joinpath(config["config_dir"], config["environment_dir"]))
    end
    return env_dir
end

"""
    get_species_dir(config::Simulation_Parameters)

Returns full path to species folder or returns config_dir/species when no path to the
species folder is provided.
"""
function get_species_dir(config::Dict{String,Any})
    if isnothing(config["species_dir"])
        spc_dir = normpath(joinpath(config["config_dir"], "species/"))
    else
        spc_dir = normpath(joinpath(config["config_dir"], config["species_dir"]))
    end
    return spc_dir
end

"""
    check_environment_dir(config::Simulation_Parameters)

Checks if the environment directory exists and throws an error if it doesn't.
"""
function check_environment_dir(config::Dict{String,Any})
    env_dir = config["environment_dir"]
    if !isdir(env_dir)
        error(
            "The specified environment directory at \"",
            env_dir,
            "\" does not exist!\n",
            "Please provide either an \"environment\" directory at \"",
            joinpath(config["config_dir"], "environment/"),
            "\" or a custom path to a directory with environment data through an ",
            "\"environment_dir\" argument in your configuration file!",
        )
    end
end

"""
    check_species_dir(config::Simulation_Parameters)

Checks if the species directory exists and throws an error if it doesn't.
"""
function check_species_dir(config::Dict{String,Any})
    spc_dir = config["species_dir"]
    if !isdir(spc_dir)
        error(
            "The specified species directory at \"",
            spc_dir,
            "\" does not exist!\n",
            "Please provide either a \"species\" directory at \"",
            joinpath(config["config_dir"], "environment/"),
            "\" or a custom path to a directory with species data through a ",
            "\"species_dir\" argument in your configuration file!",
        )
    end
end
