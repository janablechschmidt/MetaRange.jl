###### functions for initialization ####

function ParamCalibration(
    parameter::Float64,
    exponent::Float64,
    mass::Float64,
    reference_temp::Float64,
    E::Float64,
)
    #we divide here because the numbers become too high to handle for some systems otherwise
    #find another way to get this to work without magic number. priority: low
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
    initialize_abundances(
        SP::Simulation_Parameters,
        habitat::Array{Float64, 2},
        carry::Float64)

Initialization of Abundances.
"""
function initialize_abundances(
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
    initialize_output(
    SP::Simulation_Parameters,
    LS::Landscape,
    abundances::Array{Int64,3},
    habitat::Array{Float64,3},
)

Initializes the output struct. Calculation of the first timesteps is done outside the
function.
"""
function initialize_output(
    SP::Simulation_Parameters,
    LS::Landscape,
    abundances::Array{Int64,3},
    habitat::Array{Float64,3},
)
    carry_out = zeros(Float64, LS.ylength, LS.xlength, SP.timesteps)
    growrate_out = zeros(Float64, LS.ylength, LS.xlength, SP.timesteps)
    bevmort_out = zeros(Float64, LS.ylength, LS.xlength, SP.timesteps)
    return Output(abundances, habitat, carry_out, growrate_out, bevmort_out)
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
    return species["max_dispersal_dist"] = floor(Int, species["max_dispersal_dist"])
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
    sp_sanity_checks!(config::Dict)

Check if necessary configuration fields are missing
"""
function sp_sanity_checks!(config::Dict)
    for key in keys(config)
        if isnothing(config[key])
            msg = "Argument \"" * key * "\" is missing in configuration.csv!"
            error(msg)
        end
    end
    # Sanity Checks
    if config["timesteps"] < 1
        msg = "\"timesteps\" is " * config["timesteps"] * ", it has to be larger than 1!"
        error(msg)
    end
    #if !ispath(config["output_dir"])
    #    #TODO: Sanity check sholdn't write or modify files
    #    mkpath(config["output_dir"])
    #    @info("Output directory created at: ", config["output_dir"])
    #end
    #normalize path formatting
    check_environment_dir(config)
    return check_species_dir(config)
end
#TODO check if invasion boundaries are within landsape

## auxillary functions for the reading of landscape parameters (environment folder)
"""
    check_for_nan(attribute::Array{Float64})

Checks for NaNs in parameter matrix
"""
function check_for_nan(attribute::Array{Float64})
    if any(isnan.(attribute))
        msg = "$key matrix contains NA"
        error(msg)
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
            error(msg)
        end
    elseif key == "precipitation"
        # special checks for environment attribute precipitation
        if any(x -> x <= 0, attribute)
            msg = string(
                "Precipitation below 0 detected, something is wrong with the provided ",
                "precipitation data!",
            )
            error(msg)
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
        error(msg)
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
        error(msg)
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
            error(msg)
            #stop()
        end
    end
    if !isinteger(change_onset)
        msg = "change_onset not integer"
        error(msg)#;stop()
    end
    # if 2<change_onset<timesteps == false
    #   msg = "change_onset not within 2:timesteps. No enviromental change will be used"
    #   error(msg)
    # end
    if !isinteger(timesteps) || timesteps < 0
        msg = "timesteps not positive integer"
        error(msg)
        #stop
    end
    if !isa(sd, Number) || sd < 0
        msg = "sd not positive numeric"
        error(msg)
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
            error(msg)
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
            error(msg)
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
        error(msg)
    end

    # check if all inputs are defined for sufficiently many timesteps
    if any(k -> size(k[2])[3] < timesteps, all_properties)
        filter!(k -> size(k[2])[3] < timesteps, all_properties)
        durations = ""
        for key in keys(all_properties)
            durations = string(
                "$durations Timesteps given with $key: ",
                string(size(all_properties[key])[3]),
                "\n",
            )
        end
        msg = string(
            "Some input properties dont provide the necessary timesteps of ",
            "$timesteps. Please make sure that for each landscape property ",
            "the minimum required number of simulation timesteps are provided! \n",
            durations,
        )
        error(msg)
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
"""
    backup_config(SD::Simulation_Data, backup_path::String)

Record the settings actually used for a simulation run and creates a config file that can be
used for future replicate runs.
"""
function backup_config(SP::Simulation_Parameters, backup_path::String)
    config_path = joinpath(backup_path, "configuration.csv")
    open(config_path, "w") do f
        println(f, "Argument Value")
        for k in fieldnames(typeof(SP)) #get the names of the SP object
            val = getfield(SP, k)
            if isa(val, Dict) #if the value is a dictionary
                for key in keys(val)
                    println(f, key, " ", val[key]) #print name and value
                end
            elseif occursin((r"(config|output)"), string(k))
                nothing #do not print the config_dir, config_file and output_dir
            #TODO: Maybe set output dir for the backup to the same directory as the initial simulation config? - R
            elseif occursin("dir", string(k))
                println(f, k, " ", splitpath(val)[end]) #print name and value
            else
                println(f, k, " ", val) #print name and value
            end
        end
    end
end
"""
    get_out_dir(SP::Simulation_Parameters)

Names a new output directory for the simulation used in `backup_input()`[@ref]. This
directory will only be created if backup is true or the user later saves an output into the
default paths
"""
function get_out_dir(config::Dict{String,Any})
    # set the name for the output directory
    out_name = string(
        Dates.format(now(), "yyyy-mm-dd_HH-MM-SS"), "_", config["experiment_name"]
    )
    out_dir = normpath(joinpath(config["config_dir"], config["output_dir"], out_name))
    return out_dir
end
"""
    make_out_dir(out_dir::String)

create an output directory if it does not exist
"""
function make_out_dir(out_dir::String)
    if !ispath(out_dir)
        mkpath(out_dir)
        @info("Output directory created at: ", out_dir)
    end
end

"""
    backup_input(SP::Simulation_Parameters)

Initializes the output directory. This is called when input_backup in the configuration file
is set to `true` and creates a backup of the input files in the output directory.
"""
function backup_input(SP::Simulation_Parameters)
    if SP.input_backup
        make_out_dir(SP.output_dir) #create output directory
        backup_dir = mkpath(joinpath(SP.output_dir, "input")) #create input backup directory

        #copy configuration file and set paths to species and environment folders
        backup_config(SP, backup_dir)

        # set paths for backups
        backup_species = normpath(joinpath(backup_dir, splitpath(SP.species_dir)[end]))
        backup_environment = normpath(
            joinpath(backup_dir, splitpath(SP.environment_dir)[end])
        )

        #copy species and environment folders
        ispath(SP.species_dir) && cp(SP.species_dir, backup_species) #species
        ispath(SP.species_dir) && cp(SP.environment_dir, backup_environment) #environment
    end
end
