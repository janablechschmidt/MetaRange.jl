@testset "read_input.jl" begin
    @testset "Get directories" begin
        @testset "get_species_dir" begin
            # Test when species_dir is not provided
            config = Dict{String,Any}(
                "config_dir" => "/home/user/project/", "species_dir" => nothing
            )
            @test MetaRange.get_species_dir(config) == "/home/user/project/species/"

            # Test when species_dir is provided
            config = Dict{String,Any}(
                "config_dir" => "/home/user/project/", "species_dir" => "my_species/"
            )
            @test MetaRange.get_species_dir(config) == "/home/user/project/my_species/"
        end
        @testset "get_environment_dir" begin
            # Test when environment_dir is not provided
            config = Dict{String,Any}(
                "config_dir" => "/home/user/project/", "environment_dir" => nothing
            )
            @test MetaRange.get_environment_dir(config) == "/home/user/project/environment/"

            # Test when environment_dir is provided
            config = Dict{String,Any}(
                "config_dir" => "/home/user/project/",
                "environment_dir" => "my_environment/",
            )
            @test MetaRange.get_environment_dir(config) ==
                "/home/user/project/my_environment/"
        end
    end
end
