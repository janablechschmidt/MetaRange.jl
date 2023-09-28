@testset "eco_functions.jl" begin
    Random.seed!(10)
    @testset "reproduction" begin
        Ns = rand(1:100000, 10)
        g = rand(0.01:0.01:10.0, 10)
        c = rand(0.0:0.01:100000.0, 10)
        param = [(Ns[i], g[i], c[i], nothing) for i in 1:10]
        @testset "Ricker" begin
            @testset "known cases" begin
                @test MetaRange.ReproductionRicker(100, 1.0, 100.0, nothing) == 100
                @test MetaRange.ReproductionRicker(100, 0.0, 200.0, nothing) == 100
            end
            @testset "growth" for p in param
                @test xor(MetaRange.ReproductionRicker(p...) > p[1], p[1] > p[3])
            end
        end
        @testset "Beverton" begin
            @testset "known cases" begin
                @test MetaRange.ReproductionBeverton(100, 1.0, 100.0, 1.0) == 100
                @test isnan(MetaRange.ReproductionBeverton(100, 0.0, 200.0, 1.0))
            end
            @testset "growth" begin
                n = MetaRange.ReproductionBeverton(100, 1.0, 200.0, 1.0)
                @test n < MetaRange.ReproductionBeverton(100, 2.0, 200.0, 1.0)
                @test n > MetaRange.ReproductionBeverton(100, 0.5, 200.0, 1.0)
            end
        end
    end
    @testset "MortalityBev" begin
        @testset "known cases" begin
            @test MetaRange.MortalityBev(100, 1.0) == 0
            @test MetaRange.MortalityBev(100, 0.0) == 100
        end
        @testset "stochasticity" begin
            @test MetaRange.MortalityBev(100, 0.5) < 100
            @test MetaRange.MortalityBev(100, 0.5) > 0
        end
    end
    @testset "MortalityBevNoStoch" begin
        @testset "known cases" begin
            @test MetaRange.MortalityBevNoStoch(100, 1.0) == 0
            @test MetaRange.MortalityBevNoStoch(100, 0.0) == 100
            @test MetaRange.MortalityBevNoStoch(100, 0.5) == 50
        end
    end
    @testset "BV" begin
        @testset "known cases" begin
            @test MetaRange.BV(100, 1.0, 100.0, 1.0) == 100
        end
        @testset "growth" begin
            n = MetaRange.BV(100, 1.0, 200.0, 1.0)
            @test n < MetaRange.BV(100, 2.0, 200.0, 1.0)
            @test n > MetaRange.BV(100, 0.5, 200.0, 1.0)
        end
        @testset "failcase" begin
            @test isnan(MetaRange.BV(100, 0.0, 200.0, 1.0))
        end
    end
    @testset "BVNoStoch" begin
        @testset "known cases" begin
            @test MetaRange.BVNoStoch(100, 1.0, 100.0, 1.0) == 100
            @test MetaRange.BVNoStoch(100, 0.5, 200.0, 1.0) ≈ 66.666666
        end
        @testset "growth" begin
            n = MetaRange.BVNoStoch(100, 1.0, 200.0, 1.0)
            @test n < MetaRange.BVNoStoch(100, 2.0, 200.0, 1.0)
            @test n > MetaRange.BVNoStoch(100, 0.5, 200.0, 1.0)
        end
        @testset "failcase" begin
            @test isnan(MetaRange.BVNoStoch(100, 0.0, 200.0, 1.0))
        end
    end
    @testset "DispersalNegExpKernel" begin
        Dispersalbuffer = 2
        mean_dispersal_dist = 1
        spDispKernel = MetaRange.DispersalNegExpKernel(Dispersalbuffer, mean_dispersal_dist)
        @test size(spDispKernel) == (2*Dispersalbuffer+1, 2*Dispersalbuffer+1)
        @test sum(spDispKernel) ≈ 1.0
    end
    @testset "DispersalNegExpFunction" begin
        @test MetaRange.DispersalNegExpFunction(1, 0) ≈ 0.159 atol=1e-3
        @test MetaRange.DispersalNegExpFunction(1, 1) ≈ 0.058 atol=1e-3
        @test MetaRange.DispersalNegExpFunction(2, 0) ≈ 0.039 atol=1e-3
        @test MetaRange.DispersalNegExpFunction(2, 1) ≈ 0.024 atol=1e-3
    end

    @testset "HabitatMortality" begin
        Abundances = Matrix{Union{Missing,Int64}}([1 2 3; 4 5 6; 7 8 9])
        # Test case 1
        Is_habitat = BitArray([1 1 1; 1 0 1; 1 1 1])
        expected_output = [1 2 3; 4 0 6; 7 8 9]
        @test MetaRange.HabitatMortality(Abundances, Is_habitat) == expected_output
        # Test case 2
        Is_habitat = BitArray([0 0 0; 0 0 0; 0 0 0])
        expected_output = zeros(size(Abundances))
        @test MetaRange.HabitatMortality(Abundances, Is_habitat) == expected_output
        # Test case 3
        Is_habitat = BitArray([1 1 1; 1 1 1; 1 1 1])
        expected_output = Abundances
        @test MetaRange.HabitatMortality(Abundances, Is_habitat) == expected_output
    end
end
