using MetaRange
using Random
using Test

@testset "MetaRange.jl" begin
    include("constants.jl")
    include("datastructure_constructors.jl")
    include("datastructures.jl")
    include("defaults.jl")
    include("eco_functions.jl")
    include("eco_loop_functions.jl")
    include("eco_loop.jl")
    include("initialization_functions.jl")
    include("read_input.jl")
end
