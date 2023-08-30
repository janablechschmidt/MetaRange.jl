@testset "eco_loop_functions" begin
    @testset "GetDispersalSurvival" begin
        @test MetaRange.GetDispersalSurvival(true) == MetaRange.DispersalSurvivalStoch
        @test MetaRange.GetDispersalSurvival(false) == MetaRange.DispersalSurvivalRound
    end
    @testset "GetReproductionModel" begin
        @test MetaRange.GetReproductionModel("Ricker") == MetaRange.ReproductionRicker
        @test MetaRange.GetReproductionModel("Beverton") == MetaRange.BV
        @test MetaRange.GetReproductionModel("RickerAllee") == MetaRange.ReproductionRickerAllee
        @test_throws ArgumentError MetaRange.GetReproductionModel("foo")
    end
end
