"""
    Logfile(name, [path = pwd()])

Create a new logfile with the given network `name` at `path`.

Note that the `name` does not have to be equal (or similar for
that matter) to the file name in `path`. Instead it denotes the
internal name of the network (stored as an attribute in the
file), which can be shared across log files.
"""
struct Logfile
    name::String
    path::String

    function Logfile(name::String, path::String = pwd())
        path = endswith(path, "/") || isdir(path) ? joinpath(path, _make_filename(path, name)) : path
        path = endswith(path, ".h5") ? path : path * ".h5"
        mkpath(dirname(path))
        h5open(path, "w") do root
            attrs(root)[ATTR_NETWORKNAME] = name
        end
        new(name, path)
    end
end

function _make_filename(dir, name)
    basename = replace(lowercase(name), r"\W", "")
    fname = basename
    i = 1
    while isfile(joinpath(dir, fname * ".h5"))
        fname = basename * "_" * string(i)
        i += 1
    end
    fname
end
