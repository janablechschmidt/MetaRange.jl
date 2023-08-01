### packages and files
using DelimitedFiles
using CSV
using DataFrames
using Distributions
using Random
using Statistics
using Dates
using Colors
using FFTW
#using Plots
using LinearAlgebra


include("datastructures.jl")
include("datastructure_constructors.jl")
include("read_input.jl")
include("initialization_functions.jl")
include("eco_loop.jl")
include("eco_functions.jl")
include("eco_loop_functions.jl")
include("defaults.jl")

config = "./results/data/configurations/OrchisMilitarisNaNs/"
#This loads in the specified global variables
try
    include(joinpath(pwd(),joinpath(config,"constants.jl")))
    @info("Using custom constant value definition as defined in " * config)
catch
    include("default_constants.jl")
    @info("Using standard values for constants")
end

SD = read_input(config)
@info("Input Data read successfully!")
@time Run_Simulation!(SD)

