module MetaRange

using CSV
using DataFrames
using Dates
using DelimitedFiles
using Distributions
using Random

#main module functions
export read_input
export Run_Simulation!

#main module struct
export Simulation_Data

#examples and defaults
export default_run_data

include("datastructures.jl")
include("datastructure_constructors.jl")
include("read_input.jl")
include("initialization_functions.jl")
include("eco_loop.jl")
include("eco_functions.jl")
include("eco_loop_functions.jl")
include("defaults.jl")
include("constants.jl")
end
