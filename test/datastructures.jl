@testset "datastructures" begin
    @testset "Env_Preferences" begin
        EV = MetaRange.Env_Preferences(10.0, 5.0, 7.5)
        @test EV isa MetaRange.Env_Preferences
        @test EV.upper_limit == 10.0
        @test EV.lower_limit == 5.0
        @test EV.optimum == 7.5
    end
end
