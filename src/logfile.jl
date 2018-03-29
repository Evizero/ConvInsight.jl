"""
    Logfile(id, [path = pwd()])

Create a new logfile with the given network `id` at `path`.

Note that the `id` does not have to be equal (or similar for
that matter) to the file name in `path`.
"""
struct Logfile
    id::String
    path::String

    function Logfile(id::String, path::String = pwd(); append = false)
        path = endswith(path, "/") || isdir(path) ? joinpath(path, _make_filename(path, id, append)) : path
        path = endswith(path, ".h5") ? path : path * ".h5"
        mkpath(dirname(path))
        if !append || !isfile(path)
            h5open(path, "w") do root
                # attrs(root)[ATTR_NETWORKNAME] = id
            end
        end
        new(id, path)
    end
end

function _make_filename(dir, id, append = false)
    basename = replace(id, r"\W", "")
    fname = basename
    i = 1
    append && return fname
    while isfile(joinpath(dir, fname * ".h5"))
        fname = basename * "_" * string(i)
        i += 1
    end
    fname
end
