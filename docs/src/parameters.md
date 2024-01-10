# Parameters

These are all the parameters that are needed for a simulation. For the Simulation configuration files defaults are shown here but the environment and species parameters have no defaults and have to be supplied.  

## Simulation configuration files

| Parameter                        | Default          | Type                         | Description                                                                                                                                                                         |
|----------------------------------|------------------|------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `experiment_name`                | `default`        | `String`                     | Name of the experiment.                                                                                                                                                             |
| `config_dir`                     | ``               | `String`                     | Path to the configuration file is taken from [`read_input`](@ref)name                                                                                                               |
| `output_dir`                     | `./output/`      | `String`                     | Path to the output in relation to the `configuration_csv`.                                                                                                                          |
| `species_dir`                    | `./species/`     | `String`                     | Path to the species folder relative from the configuration file. The default assumes a species folder in the same folder as the configuration file from [`read_input`](@ref)        |
| `environment_dir`                | `./environment/` | `String`                     | Path to the environment folder relative to the configuration file. The default assumes an environment folder in the same folder as the configuration file from [`read_input`](@ref) |
| `input_backup`                   | `false`          | `Bool`                       | If `true` the input files will be copied to the output folder.                                                                                                                      |
| `env_attribute_files`            | NO DEFAULT       | `Dictionary{String, String}` | Path to the environment attribute files. The parameter is the key which points to the filepath of the respective file.                                                              |
| `env_restriction_files`          | NO DEFAULT       | `Dictionary{String, String}` | Path to the environment restriction files. The parameter is the key which points to the filepath of the respective file. The Simulation can be done without restrictions.           |
| `env_attribute_mode`             | `minimum`        | `String`                     | Mode for the environment attributes. Can be TODO                                                                                                                                    |
| `env_restriction_mode`           | `minimum`        | `String`                     | Mode for the environment restrictions. Can be TODO                                                                                                                                  |
| `attribute_restriction_blending` | `multiplication` | `String`                     | Mode for the environment restrictions. Can be TODO                                                                                                                                  |
| `timesteps`                      | `20`             | `Int`                        | Number of timesteps to run the simulation for.                                                                                                                                      |
| `randomseed`                     | `42`             | `Int`                        | Random seed for the simulation.                                                                                                                                                     |
| `reproduction_model`             | `Beverton`       | `String`                     | Sets which Reproduction model will be used in the simulation. Can be one of `Beverton`, `Ricker` or `RickerAllee`. See in TODO for more information                                 |
| `use_metabolic_theory`           | `true`           | `Bool`                       | If `true` the Metabolic Theory of Ecology(Brown et al., 2004)[^1] will be applied in calculation of TODO                                                                            |
| `use_stoch_allee`                | `false`          | `Bool`                       | If `true` Allee effects will have a random component                                                                                                                                |
| `use_stoch_carry`                | `false`          | `Bool`                       | If `true` the carrying capacity will have a random component                                                                                                                        |
| `use_stoch_num`                  | `false`          | `Bool`                       | If `true` the number of individuals will have a random component                                                                                                                    |
| `initialize_cells`               | `habitat`        | `String`                     | Sets where the species will be initialized. Can be one of TODO                                                                                                                      |

!!! note
    Environmental parameters have no predefined default name or value. They are supplied through the environment files and require the use
    of the same name in the species configuration files. Temperature is always required for the Metabolic Theory of Ecology. For a parameter p
    there should be a file `p.csv` in the environment folder.  
    For this case in the options it would be:
    ```
    p p.csv
    ```
    or if there is several files for `p`:  
    ```
    p p/
    ```

## Species configuration files

!!! warning
    Species configuration files have no defaults. All parameters have to be supplied in the file.

| Parameter                    | Type     | Description                                                                                      |
|------------------------------|----------|--------------------------------------------------------------------------------------------------|
| `species_name`               | `String` | Name of the species.                                                                             |
| `mass`                       | `Float`  | Mass of the individuals TODO:(is that right?).                                                   |
| `sd_mass`                    | `Float`  | Standard deviation of the mass of the individuals.                                               |
| `growrate`                   | `Float`  | Growth rate of the individuals.                                                                  |
| `sd_growrate`                | `Float`  | Standard deviation of the growth rate of the individuals.                                        |
| `param_const_growrate`       | `Float`  | TODO                                                                                             |
| `prob_dispersal`             | `Float`  | Probability of the species to disperse. TODO not currently in use                                |
| `max_dispersal_dist`         | `Int`    | Maximum distance the species can disperse.                                                       |
| `max_dispersal_buffer`       | `Int`    | Buffer around the maximum distance the species can disperse. TODO needed?                        |
| `mean_dispersal_dist`        | `Int`    | Mean distance the species can disperse.                                                          |
| `allee`                      | `Float`  | TODO                                                                                             |
| `sd_allee`                   | `Float`  | Standard deviation of the Allee effect.                                                          |
| `param_const_allee`          | `Float`  | TODO                                                                                             |
| `bevmort`                    | `Float`  | TODO                                                                                             |
| `sd_bevmort`                 | `Float`  | Standard deviation of the Beverton mortality.                                                    |
| `param_const_bevmort`        | `Float`  | TODO                                                                                             |
| carry                        | `Float`  | Carrying capacity of the species.                                                                |
| `sd_carry`                   | `Float`  | Standard deviation of the carrying capacity.                                                     |
| `param_const_carry`          | `Float`  | TODO                                                                                             |
| `upper_limit_temperature`    | `Float`  | Upper limit of the temperature range.                                                            |
| `lower_limit_temperature`    | `Float`  | Lower limit of the temperature range.                                                            |
| `optimum_temperature`        | `Float`  | Optimum temperature of the species.                                                              |
| `response_temperature`       | `String` | Response of the species to temperature. Can be one of `linear`, `quadratic`, `sqrt` or `normal`. |
| `habitat_cutoff_suitability` | `Float`  | TODO                                                                                             |

!!! note
    The general pattern of response for to an environmental preference p is:  
    - `upper_limit_p`: Upper limit of the parameter range.
    - `lower_limit_p`: Lower limit of the parameter range.
    - `optimum_p`: Optimum value of the parameter.
    - `response_p`: Response of the species to the parameter. Can be one of `linear`, `quadratic`, `sqrt` or `normal`.

[^1]: Brown, James H., et al. "Toward a metabolic theory of ecology." Ecology 85.7 (2004): 1771-1789. <https://doi.org/10.1890/03-9000>
