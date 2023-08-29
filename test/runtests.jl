using MetaRange
using Random
using Test

@testset "MetaRange.jl" begin
    include("constants.jl")
    include("eco_functions.jl")
    include("eco_loop_functions.jl")
    include("read_input.jl")
    include("initialization_functions.jl")
end
