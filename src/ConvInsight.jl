module ConvInsight

using HDF5

export

    Logfile,
    log_metadata!,
    log_timeseries!

const ATTR_NETWORKNAME = "name"

const GROUP_TIMESERIES = "timeseries"
const DATA_TIMESERIES_TIME = "time"
const DATA_TIMESERIES_STEPS = "steps"
const DATA_TIMESERIES_VALUE = "value"

include("hdf5.jl")
include("logfile.jl")
include("metadata.jl")
include("timeseries.jl")

end # module
