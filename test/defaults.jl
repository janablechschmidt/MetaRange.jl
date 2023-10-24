@testset "defaults" begin
    @testset "get_default_ls_timeseries_config" begin
        c = MetaRange.get_default_ls_timeseries_config()
        @test c isa Dict{String,Any}
        @test c["prediction"] == 0
        @test c["change_onset"] == 0
        @test c["sd"] == 0
    end
    @testset "default_run_data" begin
        #SD = default_run_data()
        SD = nothing
        @test_broken typeof(SD) == Simulation_Data
    end
end
