module ConvInsight

using HDF5

export

    Logfile,
    log_metadata!,
    log_scalar!

function _make_filename(name)
    basename = replace(lowercase(name), r"\W", "")
    fname = basename
    i = 1
    while isfile(fname * ".h5")
        fname = basename * "_" * string(i)
        i += 1
    end
    fname
end

struct Logfile
    name::String
    path::String

    function Logfile(name::String, path::String = "./")
        path = endswith(path, "/") ? joinpath(path, _make_filename(name)) : path
        path = endswith(path, ".h5") ? path : path * ".h5"
        mkpath(dirname(path))
        h5open(path, "w") do root
            attrs(root)["__NAME__"] = name
        end
        new(name, path)
    end
end

function log_metadata!(lf::Logfile; metadata...)
    h5open(lf.path, "r+") do root
        root_atr = attrs(root)
        for (name_symb, value) in metadata
            name = string(name_symb)
            name == "__NAME__" && error("metadata attribute \"__NAME__\" is reserved!")
            if HDF5.h5a_exists(root.id, name)
                a_delete(root, name)
            end
            root_atr[name] = value
        end
    end
    nothing
end

function log_scalar!(lf::Logfile, iter::Int; series...)
    h5open(lf.path, "r+") do root
        grp = exists(root, "timeseries") ? root["timeseries"] : g_create(root, "timeseries")
        time = div(Int(Dates.value(now())), 1000)
        for (name_symb, value) in series
            name = string(name_symb)
            if exists(grp, name)
                series_grp = grp[name]
                series_t = series_grp["time"]
                series_x = series_grp["iter"]
                series_y = series_grp["value"]
                len = Int(HDF5.get_dims(series_y)[1][1])
                set_dims!(series_t, (len+1,))
                set_dims!(series_x, (len+1,))
                set_dims!(series_y, (len+1,))
                series_t[len+1] = [time]
                series_x[len+1] = [iter]
                series_y[len+1] = [value]
            else
                series_grp = g_create(grp, name)
                series_t = d_create(series_grp, "time", Int, ((1,),(-1,)), "chunk", (50,))
                series_x = d_create(series_grp, "iter", Int, ((1,),(-1,)), "chunk", (50,))
                series_y = d_create(series_grp, "value", typeof(value), ((1,),(-1,)), "chunk", (50,))
                series_t[1] = [time]
                series_x[1] = [iter]
                series_y[1] = [value]
            end
        end
    end
end


end # module
