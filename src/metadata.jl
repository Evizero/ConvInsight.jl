"""
    log_metadata!(file::Logfile, metadata[...])

Write top level metadata to the given logfile. This is useful for
describing your whole network in whatever aspect you wish.

```julia
file = Logfile("My Network", tempdir())
# metadata can be specified using keyword arguments
log_metadata!(file, description = "foo", layers = 3, learningrate = 0.001)
# providing a Dict is also possible
log_metadata!(file, Dict("nhidden" => 200, "lambda" = 0.01))
```
"""
log_metadata!(lf::Logfile; args...) = log_metadata!(lf, args)

function log_metadata!(lf::Logfile, args)
    h5open(lf.path, "r+") do root
        for (name_symb, value) in args
            name = string(name_symb)
            name == ATTR_NETWORKNAME && error("metadata attribute \"$ATTR_NETWORKNAME\" is reserved!")
            a_overwrite(root, name, value)
        end
    end
    nothing
end
