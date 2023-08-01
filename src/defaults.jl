## defaults for input creation
function get_default_simulation_parameters()
    A = Dict{String, Any}(
    "experiment_name" => "default",
    "config_dir" => nothing,
    "output_dir" => "./results/data/output/",
    "species_dir" => nothing,
    "environment_dir" => nothing, # Default value gets built in the read_sp function!
    "input_backup" => false,
    "env_attribute_mode" => "minimum",
    "env_restriction_mode" => "minimum",
    "env_attribute_files" => "",
    "attribute_restriction_blending" => "multiplication",
    # "ls_timeseries_config" => "default",
    "timesteps" => 20,
    "randomseed" => 42,
    "reproduction_model" => "Beverton",
    "use_metabolic_theory" => true,
    "use_stoch_allee" => false,
    "use_stoch_carry" => false,
    "use_stoch_num" => false,
    "initialize_cells" => "habitat",
    "ls_cell_biomass_cap" => 200.0
    )
end

# defaults for input creation without user input
function get_testrun_simulation_parameters()
  #env_attribute_files = Dict{String, String}(
  #  "precipitation" => "none",
  #  "temperature" => "none")
  #  env_restriction_files = Dict{String, String}()
  A = Dict{String, Any}(
  "experiment_name" => "testrun",
  "config_dir" => nothing,
  "output_dir" => "./results/data/output/",
  "species_dir" => "notreal",
  "environment_dir" => "notreal",
  "input_backup" => false,
  "env_attribute_mode" => "minimum",
  "env_restriction_mode" => "minimum",
  "env_attribute_files" => Dict{String, String}(),
  "env_restriction_files" => Dict{String, String}(),
  "attribute_restriction_blending" => "multiplication",
  "timesteps" => 20,
  "randomseed" => 42,
  "reproduction_model" => "Beverton",
  "use_metabolic_theory" => true,
  "use_stoch_allee" => false,
  "use_stoch_carry" => false,
  "use_stoch_num" => false,
  "initialize_cells" => "habitat",
  "ls_cell_biomass_cap" => 200.0
  )
  config_path = "./TESTRUN"
  if !isdir(config_path)
    mkdir(config_path)
  end
  A["config_dir"] = config_path
  sp_sanity_checks!(A)
  #return A
  return get_Simulation_Parameters(A)
end

function get_default_ls_timeseries_config()
    return Dict{String, Any}(
    "prediction" => 0,
    "change_onset" => 0,
    "sd" => 0
    )
end

# get a random landscape for testing if the model runs
# TODO maybe make randomness not over time?
function get_default_LS()
    environment = Dict{String, Array{Float64, 3}}() 
    landscape_size = (20,20)
    timesteps = 25
    environment["temperature"] = Array{Float64, 3}(undef, landscape_size[1], landscape_size[2], timesteps)
    fill!(environment["temperature"], 293.15)
    environment["temperature"] .+= randn(size(environment["temperature"])) .* 2.5
    environment["precipitation"] = Array{Float64, 3}(undef, landscape_size[1], landscape_size[2], timesteps)
    fill!(environment["precipitation"], 500)
    environment["precipitation"] .+= randn(size(environment["precipitation"])) .* 100
    restrictions = Array{Float64, 3}(undef, landscape_size[1], landscape_size[2], timesteps)
    fill!(restrictions, 1)
    environment["temperature"][14:16,14:16,1:25] .= NaN
    environment["precipitation"][14:16,14:16,1:25] .= NaN
    return Landscape(
    landscape_size[2], #xlength
    landscape_size[1], #ylength
    environment,
    restrictions,
    Matrix{Float64}(undef, landscape_size[1], landscape_size[2])
    )
end

function species_default()
    return Dict{String, Any}(
    "species_name" => "default",
    "mass" => "0.01",
    "sd_mass" => "0",
    "growrate" => "1.7",
    "sd_growrate" => "0",
    "max_dispersal_dist" => "3",
    "mean_dispersal_dist" => "1",
    "allee" => "-200",
    "sd_allee" => "0",
    "bevmort" => "0.3",
    "sd_bevmort" => "0",
    "carry" => "200",
    "sd_carry" => "0",
    "upper_limit_temperature" => "303.15",
    "lower_limit_temperature" => "283.15",
    "optimum_temperature" => "293.15",
    "upper_limit_precipitation" => "400",
    "lower_limit_precipitation" => "600",
    "optimum_precipitation" => "500",
    "habitat_cutoff_suitability" => "0.001"
    )
end

function get_default_species(LS::Landscape, SP::Simulation_Parameters)
    species_vec = Species[]
    species = species_default()
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
          env_preferences[key] = get_Env_Preferences(species, key)
        end
        species["env_preferences"] = env_preferences
    
        # calibrate pop params if they weren't provided
        pop_param = ["growrate","carry","allee","bevmort"]
        exp = Dict("growrate" => exp_growrate, "carry" => exp_carry, "allee" => exp_allee, "bevmort" => exp_bevmort)
        en = Dict("growrate" => E_growrate, "carry" => E_carry, "allee" => E_allee, "bevmort" => E_bevmort)
        for param in pop_param
          if "param_const_$param" ∉ keys(species)
            # Determined in GetPopParam function later, dependent on evolving traits!
            species["param_const_$param"] = ParamCalibration(species[param], exp[param], species["mass"], species["optimum_temperature"],en[param])
          end
        end
    
        # TODO Sanity Checks
        # param_const_growrate, param_const_allee, param_const_bevmort and param_const_carry should not be 0 as they
        # produce 0s when using metabolic_theory in function GetPopParam() function which in turn produce NAN values
        # when the corresponding sd parameter is not 0 in the Randomize() function
        # bevmort can only be in range [0,1]
        # Build Traits struct
        traits = get_Traits(species)
        # calculate habitat
        habitat_init = get_habitat(traits.env_preferences,LS,SP.env_attribute_mode,1)
        habitat = Array{Float64, 3}(undef, size(habitat_init)[1], size(habitat_init)[2],SP.timesteps)
        habitat[:,:,1] = habitat_init
        # initialize abundances
        abundances = InitializeAbundances(SP,habitat[:,:,1],traits.carry)
        dispersal_kernel = DispersalNegExpKernel(traits.max_dispersal_dist, traits.mean_dispersal_dist)
        # total_abundance = Vector{Union{Nothing,Int64}}(undef,SP.timesteps)
        push!(species_vec ,Species(species["species_name"],traits,abundances,habitat,dispersal_kernel,get_Simulation_Variables()))
end

function default_run_data()
  landscape = get_default_LS()
  parameters = get_testrun_simulation_parameters()
  #duration = Duration
  species = get_default_species(landscape, parameters)
  return Simulation_Data(parameters, landscape, species, Duration(now(),now()))
end

# what do you need for simulation data struct?
# SD hat landscape, parameters, species, duration
