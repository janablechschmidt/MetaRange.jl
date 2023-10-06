@testset "eco_loop" begin
    @testset "run_simulation" begin
        SD = read_input("testfiles/testconfig/configuration.csv")
        run_simulation!(SD)
        @test SD != read_input("testfiles/testconfig/configuration.csv")
    end
end
