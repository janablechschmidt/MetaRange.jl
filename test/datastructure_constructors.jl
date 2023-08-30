@testset "datastructure_constructors" begin
    @testset "get_Simulation_Variables" begin
        @testset "returns a Simulation_Variables object" begin
            @test MetaRange.get_Simulation_Variables() isa MetaRange.Simulation_Variables
        end
        @testset "assert fields" begin
            SV = MetaRange.get_Simulation_Variables()
            @test SV.habitat isa Array{Float64}
            @test SV.is_habitat isa BitArray{2}
            @test SV.future_habitat isa Array{Float64}
            @test SV.future_is_habitat isa BitArray{2}
            @test SV.biomass isa Array{Float64}
            @test SV.growrate isa Array{Float64}
            @test SV.carry isa Array{Float64}
            @test SV.allee isa Array{Float64}
            @test SV.bevmort isa Array{Float64}
            @test SV.occurrences isa Vector{CartesianIndex{2}}
            @test SV.offspring isa Array{Float64}
        end
    end
end
