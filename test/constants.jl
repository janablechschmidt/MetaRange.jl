@testset "constants" begin
    @test MetaRange.E_allee == 0.65
    @test MetaRange.E_bevmort == 0.65
    @test MetaRange.E_carry == -0.65
    @test MetaRange.E_growrate == 0.65
    @test MetaRange.k_jk == 1.380649e-23
    @test MetaRange.e == 1.602176634e-19
    @test MetaRange.k == MetaRange.k_jk / MetaRange.e
    @test MetaRange.k == 8.617333262145179e-5
    @test MetaRange.exp_allee == -0.75
    @test MetaRange.exp_bevmort == -0.25
    @test MetaRange.exp_carry == -0.75
    @test MetaRange.exp_growrate == -0.25
end
