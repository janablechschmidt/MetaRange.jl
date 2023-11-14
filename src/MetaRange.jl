module MetaRange

using CSV
using DataFrames
using Dates
using DelimitedFiles
using Distributions
using Random
#using GLMakie
using CairoMakie

#main module functions
export read_input
export run_simulation!

#output functions
export save_csv

#visualization functions
export plot_abundances
export image_suitability
export image_abundances
export image_temperature
export image_precipitation
export image_restrictions
export suitability_gif
export abundance_gif
export carry_gif
export reproduction_gif
export mortality_gif
export plot_all
export all_gif
export save_all

#examples and defaults
export default_run_data
export copy_examples

include("datastructures.jl")
include("datastructure_constructors.jl")
include("read_input.jl")
include("initialization_functions.jl")
include("eco_loop.jl")
include("eco_functions.jl")
include("eco_loop_functions.jl")
include("defaults.jl")
include("constants.jl")
include("output.jl")
end
