# MetaRange

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://janablechschmidt.github.io/MetaRange.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://janablechschmidt.github.io/MetaRange.jl/dev/)
[![Build Status](https://github.com/janablechschmidt/MetaRange.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/janablechschmidt/MetaRange.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

MetaRange is a process-based mechanistic species distribution model, that explicitly includes stochastic
as well as metabolic processes. It is intended to be used as a general mechanistic distribution model for
theoretical questions as well as a predictive tool to model future species distributions based on empirical data.

## About

MetaRange integrates spatially-explicit demographic and behavioural processes with a niche- and metabolism-based approach. For each species, it considers species-specific environmental preferences and regulates demographic processes via the Metabolic Theory of Ecology.

The user can model the spatial distribution of a species in any landscape. Niches are defined by temperature and precipitation and can include further niche axis if desired by the user. Demographic processes are adapted via the Metabolic Theory of Ecology, such that both biomass of the organism as well as temperature in a given patch influence demographic rates.

A manuscript introducing MetaRange.jl is currently in preparation.

## Installation

The package can be installed from github through the inbuilt Julia package manager. Open a Julia REPL, e.g. by running the command `julia` in your command line in the place where your Julia is installed. Then, type `]` to enter the Pkg REPL mode and run:

```text
pkg> add https://github.com/janablechschmidt/MetaRange.jl.git
```

Alternatively you can use `Pkg` directly by running:

```julia
julia> import Pkg; Pkg.add(url = "https://github.com/janablechschmidt/MetaRange.jl.git")
```

This will download all scripts, files, and dependencies that are necessary to run the model.

MetaRange has been tested on Julia 1.6 and upwards on Windows and Linux.

## Usage

MetaRange works by first creating a simulation struct and then calling the function `run_simulation!()` on the object. There are two main functions to execute a simulation. First, your input must be read and initialized with the `read_input()` function. This function will create a `Simulation_Data` struct, typically named `SD` (but you can name it whatever you want), which contains all input data as well as the structures that will hold the results, but are empty initially. `SD` can then be given to the function `run_simulation(SD)`, which will modify it to include the simulation results.  
Here is a minimum example on a random landscape, which will run a simulation of 20 timesteps without needing any input to be provided:

```julia
using MetaRange
SD = default_run_data()
run_simulation!(SD)
```

Alternatively, you can use our `examples` folder. It is recommended to save the folder where you would like the simulation data to be saved. For the static example we provide, your code would look like this:

```julia
using MetaRange
pathname = "./static/"
SD = read_input(pathname)
run_simulation!(SD)
```

Running the simulation with your own data requires your data to be in the same format as found in our example folder. Your folder needs to contain a .csv file with configuration parameters for the model, a folder named `species` which includes a .csv file with species-specific parameters, and a folder named `environment` which includes the landscape, again in .csv format.
A detailed explanation on how to run the simulation with your own data and folder structure can be found in the [documentation](https://janablechschmidt.github.io/MetaRange.jl/dev/).

Results can be viewed by inspecting the relevant parts of the `Simulation_Data` object. There are also several visualization functions that will plot the output (see [documentation](https://janablechschmidt.github.io/MetaRange.jl/dev/) for all functions and their description). Output images can be static or dynamic. For example, to create a GIF of the abundance of a species for each timestep of the simulation call:

```julia
abundance_gif(SD)
```

![Abundance GIF](./docs/src/img/static_abundances.gif)

For further examples of usage and how to use different data for simulations as well as further description of the used objects, please refer to the [documentation](https://janablechschmidt.github.io/MetaRange.jl/dev/)

## License

This project is licensed under the terms of the **MIT** license. See `LICENSE` for more information.

## Acknowledgements

This module is an adaptation of the [metaRange](https://srfall.github.io/metaRange) model written in R.  
