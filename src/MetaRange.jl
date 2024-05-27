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
export df_output
export save_output

#visualization functions
export plot_abundances
export img
export gif
export img_complex
export gif_complex
export save_all

#examples and defaults
export demo_input

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
