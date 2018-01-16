using ConvInsight
using Base.Test
using HDF5

@testset "LogFile" begin
    lf = Logfile("foo !bar", tempdir()) # custom dir
    @test lf.path == joinpath(tempdir(), "foobar.h5")
    @test lf.name == "foo !bar"
    @test lf.name == h5open(lf.path, "r") do root
        read(attrs(root)["name"])
    end
    rm(lf.path)
    path = tempname() # custom filename
    lf = Logfile("foo !bar", path)
    @test lf.path == path * ".h5"
    @test lf.name == "foo !bar"
    @test lf.name == h5open(lf.path, "r") do root
        read(attrs(root)["name"])
    end
    rm(lf.path)
end

@testset "metadata" begin
    lf = Logfile("testfile", tempdir()) # custom dir
    log_metadata!(lf, foo = 2.3, bar = 4, baz = "5")
    h5open(lf.path, "r") do root
        @test 4 == length(names(attrs(root)))
        @test 2.3 === read(attrs(root)["foo"])
        @test 4 === read(attrs(root)["bar"])
        @test "5" == read(attrs(root)["baz"])
    end
    log_metadata!(lf, Dict("bar" => 6, "baz" => 5))
    h5open(lf.path, "r") do root
        @test 4 == length(names(attrs(root)))
        @test 2.3 === read(attrs(root)["foo"])
        @test 6 === read(attrs(root)["bar"])
        @test 5 == read(attrs(root)["baz"])
    end
    rm(lf.path)
end

@testset "timeseries" begin
    lf = Logfile("testfile", tempdir()) # custom dir
    log_timeseries!(lf, 2, int = 2)
    log_timeseries!(lf, 5, Dict("acc" => 0.2, "int" => 1))
    log_timeseries!(lf, 6, acc = 0.5, int = 0)
    h5open(lf.path, "r") do root
        @test 2 == length(names(root["timeseries"]))
        @test [2,5,6] == read(root["timeseries/int/iter"])
        @test [2,1,0] == read(root["timeseries/int/value"])
        @test read(root["timeseries/int/value"]) isa Vector{Int}
        @test [5,6] == read(root["timeseries/acc/iter"])
        @test [0.2,0.5] == read(root["timeseries/acc/value"])
        @test read(root["timeseries/acc/value"]) isa Vector{Float64}
        @test read(root["timeseries/int/time"])[2:3] == read(root["timeseries/acc/time"])
    end
    rm(lf.path)
end
