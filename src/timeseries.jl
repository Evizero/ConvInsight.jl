function log_timeseries!(lf::Logfile, step::Int; args...)
    log_timeseries!(lf, step, args)
end

function log_timeseries!(lf::Logfile, step::Int, args)
    h5open(lf.path, "r+") do root
        # create "/timeseries" super group if it does not yet exist
        supergroup = g_create_or_get(root, GROUP_TIMESERIES)
        # compute time stamp for current entry
        time = div(Int(Dates.value(now())), 1000)
        for (name_symb, value) in args
            @assert value isa Number
            name = string(name_symb)
            # check if the "/timeseries/$name" group for current
            # series already exists or not
            subgroup = g_create_or_get(supergroup, name)
            # push the values to the data arrays
            d_create_and_push(subgroup, DATA_TIMESERIES_TIME, time)
            d_create_and_push(subgroup, DATA_TIMESERIES_STEPS, step)
            d_create_and_push(subgroup, DATA_TIMESERIES_VALUE, value)
        end
    end
end
