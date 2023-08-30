@testset "read_input.jl" begin
    @testset "ParamCalibration" begin
        @test MetaRange.ParamCalibration(0.0 , 1.0, 1.0, 297.0, 0.65) == 0
        #test that if exponent == 1.0 mass has no effect
        p = MetaRange.ParamCalibration(1.0, 1.0, 1.0, 297.0, 0.65)
        @test p == MetaRange.ParamCalibration(1.0, 10.0, 1.0, 297.0, 0.65)
    end
end
