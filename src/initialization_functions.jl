###### functions for initialization ####

function ParamCalibration(
    parameter::Float64,
    exponent::Float64,
    mass::Float64,
    reference_temp::Float64,
    E::Float64,
)
    #we divide here because the numbers become too high to handle for some systems otherwise
    #honestly not a fan of magic numbers, could this be fixed in another way? - R
    param_const =
        parameter / ((mass^(exponent)) * exp(-E / (k * reference_temp))) / 500000000000
    return param_const
end

##mte
function MetabolicRate(
    param_const::Float64,
    exponent::Float64,
    mass::Array{Float64,2},
    temperature::SubArray{Float64,2,Array{Float64,3}},
    E::Float64,
)
    # bodymass dependent - demographic
    Mass1 = mass .^ (exponent)
    # temperature dependent - environment)
    T1 = exp.(-E ./ (k .* temperature))
    ## we multiply here because we divided by this factor earlier
    modified_parameter = param_const .* Mass1 .* T1 .* 500000000000
    return modified_parameter
end

### TODO re-write this as calculation of habitat suitability, not tolerance
function get_habitat_suit(vmax, vopt, vmin, venv)
    left = ((vmax .- venv) ./ (vmax - vopt))
    right = ((venv .- vmin) / (vopt - vmin))
    right[right .< 0] .= 0
    ex = ((vopt - vmin) / (vmax - vopt))
    res = left .* right .^ ex
    res[res .< 0] .= 0
    return res
end

"""
    InitializeAbundances(
        SP::Simulation_Parameters,
        habitat::Array{Float64, 2},
        carry::Float64)

Initialization of Abundances.
"""
function InitializeAbundances(
    SP::Simulation_Parameters, habitat::Array{Float64,2}, carry::Float64
)
    abundances = zeros(Int, size(habitat)[1], size(habitat)[2], SP.timesteps) # x y z
    if SP.initialize_cells == "all"
        abundances[:, :, 1] =
            round.(Int, rand(0:(carry / 10), size(habitat)[1], size(habitat)[2]))
        pos = findall(isnan.(habitat))
        zusatz = zeros(size(habitat))
        zusatz[:, :] = abundances[:, :, 1]
        zusatz[pos] .= 0
        abundances[:, :, 1] = zusatz

    elseif SP.initialize_cells == "habitat"
        zusatz = zeros(size(habitat))
        pos = findall(isnan.(habitat))
        #println("nans in habitat:")
        #println(pos)
        zusatz[:, :] = habitat[:, :]
        zusatz[pos] .= 0
        abundances[:, :, 1] = round.(Int, carry .* zusatz)
        #println("zeros in abundances:")
        #findall(abundances[:,:,1].==0)
    end
    return abundances
end

"""
    randomize!(value,sd)

Takes a parameter or array of parameters and modifies it according to a lognormal
distribution based on standard deviation sd
"""
function randomize!(value, sd)
    if isa(value, Array)
        for i in eachindex(value)
            value[i] = randomize!(value[i], sd)
        end
    elseif isa(value, Float64)
        if sd != 0 && value > 0 #additional check for sd != 0 because change otherwise
            mu = log(value^2 / sqrt((sd^2) + (value^2)))
            sig = sqrt(log(1 + ((sd^2) / (value^2))))
            value = rand(LogNormal(mu, sig))
        end
    end
    return value
end

## Performs Sanity Check on constants
function check_constants()
    # TODO implement this
end

## functions to parse strings in dicts to julia datatypes

# Convert all string formatted numeric arguments to julia numeric types
function parse_fields_numeric!(dict::Dict)
    for key in keys(dict)
        parsed = tryparse(Int, dict[key])
        if !isnothing(parsed)
            dict[key] = parsed
        else
            parsed = tryparse(Float64, dict[key])
            if !isnothing(parsed)
                dict[key] = parsed
            end
        end
    end
end

# Convert all boolean arguments to actual Julia booleans
function parse_fields_bool!(dict::Dict)
    for key in keys(dict::Dict)
        if dict[key] == "false" || dict[key] == "true"
            dict[key] = dict[key] == "true" ? true : false
        end
    end
end

"""
    parse_species_datatypes!(species::Dict)

Convert all Float and Integer arguments to their respective Julia types (as needed for
the species)
"""
function parse_species_datatypes!(species::Dict)
    for key in keys(species)
        parsed = tryparse(Float64, species[key])
        if !isnothing(parsed)
            species[key] = parsed
        end
    end
    for key in ("max_dispersal_dist", "mean_dispersal_dist")
        species[key] = floor(Int, species[key])
    end
end

"""
    parse_environment_parameters!(config::Dict, input_config::Dict)

Build the Dicts containing environment attribute and restriction files.
"""
function parse_environment_parameters!(config::Dict, input_config::Dict)
    # 1. get the environment parameters (defined as all "unexpected" keys!)
    env_parameters = filter(
        x -> x ∉ keys(get_default_simulation_parameters()), keys(input_config)
    )
    # 2. divide the parameters into the environment attributes and restrictions
    env_attributes = filter(x -> !occursin("restriction", x), env_parameters)
    env_restrictions = filter(x -> occursin("restriction", x), env_parameters)
    # 3. initialize, build the respective dicts and assigne them to the config dict
    env_attribute_files = Dict{String,String}()
    env_restriction_files = Dict{String,String}()
    #print environmental attributes and set in dictionary
    for key in env_attributes
        println(key)
        env_attribute_files[key] = input_config[key]
    end
    for key in env_restrictions
        env_restriction_files[key] = input_config[key]
    end
    #check if any environment attribute files have been defined
    if isempty(env_attribute_files)
        error("No environment attribute files have been defined in the configuration ")
    end
    #update dictionary
    config["env_attribute_files"] = env_attribute_files
    return config["env_restriction_files"] = env_restriction_files
end

## auxillary functions for the reading of simulation parameters (configuration.csv)
"""
    check_speciesdir!(config::Dict, config_path::String)

Check if species directory was given and apply default path if not
"""
function check_speciesdir!(config::Dict, config_path::String)
    if isnothing(config["species_dir"])
        config["species_dir"] = config_path * "species/"
        if !isdir(config["species_dir"])
            msg = string(
                "\"species\" directory is missing in the configuration input folder!\n",
                "Please provide either a \"species\" directory at \"$config_path\" or ",
                "provide a custom path to a directory with species data with a ",
                "\"species_dir\" argument in \"configuration.csv\"!",
            )
            throw(ErrorException(msg))
        end
        #TODO Except empty species dir
    else
        if !isdir(config["species_dir"])
            msg = string(
                "The specified species directory at $(config["species_dir"]) ",
                "does not exist!",
            )
            throw(ErrorException(msg))
        end
    end
end

"""
    check_environmentdir!(config::Dict, config_path::String)

Check if environment directory was given and apply default path if not.
"""
function check_environmentdir!(config::Dict, config_path::String)
    if isnothing(config["environment_dir"])
        config["environment_dir"] = config_path * "environment/"
        if !isdir(config["environment_dir"])
            msg = string(
                "\"environment\" directory is missing in the configuration input ",
                " folder!\n",
                "Please provide either an \"environment\" directory at ",
                "\"$config_path\" or provide a custom path to a directory with ",
                "environment data with an \"environment_dir\" argument in ",
                "\"configuration.csv\"!",
            )
            throw(ErrorException(msg))
        end
    else
        if !isdir(config["environment_dir"])
            msg = string(
                "The specified environment directory at \"",
                config["environment_dirraw"],
                "\" does not exist!",
            )
            throw(ErrorException(msg))
        end
    end
end

"""
    sp_sanity_checks!(config::Dict)

Check if necessary configuration fields are missing
"""
function sp_sanity_checks!(config::Dict)
    for key in keys(config)
        if isnothing(config[key])
            msg = "Argument \"" * key * "\" is missing in configuration.csv!"
            throw(ErrorException(msg))
        end
    end
    # Sanity Checks
    if config["timesteps"] < 1
        msg = "\"timesteps\" is " * config["timesteps"] * ", it has to be larger than 1!"
        throw(ErrorException(msg))
    end
    if !ispath(config["output_dir"])
        mkpath(config["output_dir"])
        @info("Output directory created at: ", config["output_dir"])
    end
    #normalize path formatting
    if !endswith(config["output_dir"], "/")
        config["output_dir"] = config["output_dir"] * "/"
    end
    if !endswith(config["species_dir"], "/")
        config["species_dir"] = config["species_dir"] * "/"
    end
    if !endswith(config["environment_dir"], "/")
        config["environment_dir"] = config["environment_dir"] * "/"
    end
    #TODO check if invasion boundaries are within landsape
end

## auxillary functions for the reading of landscape parameters (environment folder)
"""
    check_for_nan(attribute::Array{Float64})

Checks for NaNs in parameter matrix
"""
function check_for_nan(attribute::Array{Float64})
    if any(isnan.(attribute))
        msg = "$key matrix contains NA"
        throw(ErrorException(msg))
    end
end

"""
    check_attribute_values!(attribute::Array{Float64}, key::String)

Sanity checks for Attribute Matrices. Will convert Celsius values to Kelvin.
"""
function check_attribute_values!(attribute::Array{Float64}, key::String)
    if key == "temperature"
        #special checks for environment attribute temperature
        meantemp = mean(filter(!isnan, attribute))
        if meantemp < 60
            @info("Input temperature seems to be in Celsius, converting to Kelvin")
            attribute .+= 273.15
        elseif meantemp < 200
            @warn(
                string(
                    "Mean of input temperature seems to be too high to assume Celsius ",
                    "values and too low to assume Kelvin values.\n Results will likely ",
                    "make no sense. Unless you're trying to simulate alien life, please ",
                    "check your input!",
                )
            )
        elseif meantemp < 360
            @info("Temperature input values are assumed to be in Kelvin.")
        else
            @warn(
                string(
                    "Input temperatures seem unusually high with a mean temperature of ",
                    meantemp,
                    ", please make sure to check your input.",
                )
            )
        end
        if any(x -> x <= 0, attribute)
            msg = string(
                "Temperature below 0 Kelvin detected, something is wrong with the ",
                "provided temperature data!",
            )
            throw(ErrorException(msg))
        end
    elseif key == "precipitation"
        # special checks for environment attribute precipitation
        if any(x -> x <= 0, attribute)
            msg = string(
                "Precipitation below 0 detected, something is wrong with the provided ",
                "precipitation data!",
            )
            throw(ErrorException(msg))
        end
        #Implement further sanity checks as needed!
    end
end

function check_restriction_values!(restriction::Array{Float64}, key::String)
    #TODO Sanity checks on restriction values
    return x = 1 #dummy
end

function read_env_para_dir(env_dir::String, dir::String, key::String)
    param_dir = joinpath(env_dir, dir)
    param_files = sort_dir(readdir(param_dir))
    if isempty(param_files)
        msg = """the directory "$param_dir" of environment parameter $key is empty."""
        throw(ErrorException(msg))
    end
    # read first timestep to get the required dimensions for the matrix
    param_init = readdlm(joinpath(param_dir, param_files[1]), ' ', Float64)
    parameter = Array{Float64,3}(
        undef, size(param_init)[1], size(param_init)[2], length(param_files)
    )
    # optimization: save the matrix used to get the dimensions into the first timestep
    parameter[:, :, 1] = param_init
    for i in 2:length(param_files)
        parameter[:, :, i] = readdlm(joinpath(param_dir, param_files[i]), ' ', Float64)
    end
    return parameter
end

function sort_dir(x::Vector{String})
    f = text -> all(isnumeric, text) ? Char(parse(Int, text)) : text
    sorter = key -> join(f(m.match) for m in eachmatch(r"[0-9]+|[^0-9]+", key))
    return sort(x; by=sorter)
end
## turns 2-dimensional landscape into 3 if only one input timestep is given
function CreateTimeseries(
    landscape::Matrix{Float64}, prediction, sd, change_onset, timesteps::Int64
)
    # check landscape #######
    if !isa(landscape, Array)
        msg = "landscape is not array or does not exist"
        throw(ErrorException(msg))
    end
    if any(isnan.(landscape))
        println("landscape contains NA")
    end
    if isa(prediction, Array)
        if any(isnan.(prediction))
            println("prediction contains NA")
        end
        if !all(size(landscape) == size(prediction))
            msg = "landscape & prediction do not have the same dimensions"
            throw(ErrorException(msg))
            #stop()
        end
    end
    if !isinteger(change_onset)
        msg = "change_onset not integer"
        throw(ErrorException(msg))#;stop()
    end
    # if 2<change_onset<timesteps == false
    #   msg = "change_onset not within 2:timesteps. No enviromental change will be used"
    #   throw(ErrorException(msg))
    # end
    if !isinteger(timesteps) || timesteps < 0
        msg = "timesteps not positive integer"
        throw(ErrorException(msg))
        #stop
    end
    if !isa(sd, Number) || sd < 0
        msg = "sd not positive numeric"
        throw(ErrorException(msg))
        #stop()
    end
    # start of creation #######
    res = Array{Float64}(undef, size(landscape)[1], size(landscape)[2], timesteps)
    res[:, :, 1] = landscape
    if change_onset >= 2 && change_onset <= timesteps
        if isa(prediction, Array)
            res[:, :, timesteps] = prediction
        else
            res[:, :, timesteps] = res[:, :, 1] .+ prediction
        end
        res[:, :, change_onset] = res[:, :, 1]
        res = lerp(res) # lerp is in landscape_functions
    else
        res[:, :, :] .= res[:, :, 1]
    end
    if sd > 0
        res[:, :, :] .= TempFluctuation(
            dim(landscape)[1], dim(landscape)[2], timesteps, sd, res
        )
    end
    return res
end

## Returns the Landscape Parameters as a Landscape struct
function read_ls(
    env_dir::String,
    env_attib::Dict{String,String},
    env_restr::Dict{String,String},
    timesteps::Int,
)
    environment = Dict{String,Array{Float64,3}}()
    # read environment attributes
    for key in keys(env_attib)
        attribute = Nothing
        # If a single file is given, read it and create a timeseries of required length
        if isfile(joinpath(env_dir, env_attib[key]))
            attribute = readdlm(joinpath(env_dir, env_attib[key]), ' ', Float64)
            # Generate timeseries data
            attribute = CreateTimeseries(attribute, 0, 0, 0, timesteps)
            # If a directory is given, read its content as a fileseries
        elseif ispath(joinpath(env_dir, env_attib[key]))
            attribute = read_env_para_dir(env_dir, env_attib[key], key)
        else
            msg = string(
                "$key file or directory $(env_attib[key]), does not exist at specified ",
                "environment data location: $env_dir",
            )
            throw(ErrorException(msg))
        end
        # sanity checks
        #check_for_nan(attribute)
        check_attribute_values!(attribute, key)

        environment[key] = attribute
    end
    # read environment restrictions
    restrictions = Dict{String,Array{Float64,3}}()
    for key in keys(env_restr)
        restriction = Nothing
        # check for existance of file and read file
        if isfile(joinpath(env_dir, env_restr[key]))
            restriction = readdlm(joinpath(env_dir, env_restr[key]), ' ', Float64)
            # Generate timeseries data
            restriction = CreateTimeseries(restriction, 0, 0, 0, timesteps)
        elseif ispath(joinpath(env_dir, env_restr[key]))
            restriction = read_env_para_dir(env_dir, env_restr[key], key)
        else
            msg = string(
                "$key file or directory $(env_restr[key]), does not exist at specified ",
                "environment data location: $env_dir",
            )
            throw(ErrorException(msg))
        end
        # sanity checks
        #check_for_nan(restriction)
        #check_restriction_values!(restriction, key)

        restrictions[key] = restriction
    end

    # check if sizes of all inputs match
    all_properties = merge(environment, restrictions)
    landscape_size = size(environment[collect(keys(all_properties))[1]])[1:2]
    if any(k -> size(k[2])[1:2] != landscape_size, all_properties)
        sizes = ""
        for key in keys(all_properties)
            sizes = string(
                sizes,
                "$key: (",
                string(size(all_properties[key])[1]),
                ",",
                string(size(all_properties[key])[2]),
                ") \n",
            )
        end
        msg = string(
            "Size mismatch in dimensions of provided environment data, please make ",
            "sure that they match in all dimensions! \n",
            sizes,
        )
        throw(ErrorException(msg))
    end

    # check if all inputs are defined for sufficiently many timesteps
    if any(k -> size(k[2])[3] < timesteps, all_properties)
        filter!(k -> size(k[2])[3] < timesteps, all_properties)
        durations = ""
        for key in keys(all_properties)
            durations = string(
                "$durations Timesteps given with $key: ",
                string(size(all_properties["key"])[3]),
                "\n",
            )
        end
        msg = string(
            "Some input properties dont provide the necessary timesteps of ",
            "$timesteps. Please make sure that for each landscape properties at least ",
            "the minimum required simulation timesteps are provided! \n",
            durations,
        )
        throw(ErrorException(msg))
    end

    # process restrictions
    if isempty(restrictions)
        restrictions = Array{Float64,3}(
            undef, landscape_size[1], landscape_size[2], timesteps
        )
        fill!(restrictions, 1)
    else
        #TODO implement blending of multiple restriction types
        restrictions = restrictions[collect(keys(restrictions))[1]]
    end

    # Return Landscape struct
    return Landscape(
        landscape_size[2], #xlength
        landscape_size[1], #ylength
        environment,
        restrictions,
    )
end

"""
    read_ts_config(env_dir::String, ls_timeseries_config::String)

Returns the timeseries generator configuration as a Dict (no struct as it's only used once)
"""
function read_ts_config(env_dir::String, ls_timeseries_config::String)
    ts_config = get_default_ls_timeseries_config()
    if !isfile(joinpath(env_dir, ls_timeseries_config)) && ls_timeseries_config != "default"
        warn(
            string(
                "Ls_timeseries_config file $ls_timeseries_config does not exist at specified ",
                "environment data location: $env_dir \n",
                "Falling back to default values!",
            ),
        )
        ls_timeseries_config = "default"
    end
    if ls_timeseries_config != "default"
        input_ts_config = Dict{String,Int}(
            CSV.File(joinpath(env_dir, ls_timeseries_config))
        )
        #Overwrite defaults where applicable
        for key in keys(input_ts_config)
            ts_config[key] = input_ts_config[key]
        end
    end
    return ts_config
end

function init_out_dir(SP::Simulation_Parameters)
    out_dir = joinpath(
        SP.output_dir,
        string(SP.experiment_name, Dates.format(now(), " at dd.mm.yyyy HH-MM-SS")),
    )
    mkpath(out_dir)
    if SP.input_backup
        backup_dir = joinpath(out_dir, "input")
        cp(SP.config_dir, backup_dir)
        configfile = joinpath(backup_dir, "configuration.csv")
        df = DataFrame(CSV.File(configfile))
        config = Dict{String,Any}(CSV.File(configfile))
        config["species_dir"] = replace(joinpath(backup_dir, "species"), "\\" => "/")
        config["environment_dir"] = replace(
            joinpath(backup_dir, "environment"), "\\" => "/"
        )
        df.Value = map(akey -> config[akey], df.Argument)
        CSV.write(configfile, df; delim=" ")
    end
end
