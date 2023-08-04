@testset "eco_functions.jl" begin
    #initialise tuples for testing
    Random.seed!(10)
    Ns = rand(1:100000, 100)
    g = rand(0.01:0.01:10.0, 100)
    c = rand(0.0:0.01:100000.0, 100)
    param = [(Ns[i], g[i], c[i], nothing) for i=1:100]
    @testset "Ricker" begin
        @testset "known cases" begin
            @test MetaRange.ReproductionRicker(100, 1.0, 100.0, nothing) == 100
            @test MetaRange.ReproductionRicker(100, 0.0, 200.0, nothing) == 100
        end
        @testset "growth" for p in param
            @test xor(MetaRange.ReproductionRicker(p...) > p[1], p[1] > p[3])
        end
    end
end
