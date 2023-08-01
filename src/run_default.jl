## packages and files
using DelimitedFiles
using CSV
using DataFrames
using Distributions
using Random
using Statistics
using Dates
using Colors
using FFTW
# using Plots
using LinearAlgebra

include("datastructures.jl")
include("datastructure_constructors.jl")
include("read_input.jl")
include("initialization_functions.jl")
include("eco_loop.jl")
include("eco_functions.jl")
include("eco_loop_functions.jl")
include("defaults.jl")
include("./default_constants.jl")

function TestRun()
    SD = default_run_data()
    @info("Running a default test version!")
    @time Run_Simulation!(SD)
    return SD
end

SD = TestRun()