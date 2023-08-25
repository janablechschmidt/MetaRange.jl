@testset "Initialization" begin
    @testset "randomize!()" begin
        Random.seed!(10)
        @testset "standard deviation" begin
            @test randomize!(10.0, 0.0) == 10.0
            @test randomize!(10.0, 0.0001) ≈ 10.0 rtol=1e-4
            m = fill(10.0, (10, 10))
            @test randomize!(m, 0.0) == m
            @test randomize!(m, 0.1) != m
        end
        @testset "zero" begin
            @test randomize!(0.0, 0.1) == 0.0
            m = zeros(Float64, 10, 10)
            @test randomize!(m, 0.0) == m
            @test randomize!(m, 0.1) == m
        end
        @testset "missing values" begin
            @test randomize!(missing, 0.2) === missing
        end
        @testset "NaNs" begin
            @test randomize!(NaN, 0.2) === NaN #return NaNs when read in for
        end
    end
end
