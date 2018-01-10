
function g_create_or_get(node, name)
    exists(node, name) ? node[name] : g_create(node, name)
end

function a_overwrite(node, name, value)
    # check if the hdf5 attribute already exists.
    # if it does we need to delete it in order to be able
    # to overwrite it.
    if HDF5.h5a_exists(node.id, name)
        a_delete(node, name)
    end
    attrs(node)[name] = value
end

function d_create_and_push(node, name, value)
    if exists(node, name)
        data = node[name]
        # simply expand the dimension by 1
        len = Int(HDF5.get_dims(data)[1][1])
        set_dims!(data, (len+1,))
        # write new entry at the new end of the arrays
        data[len+1] = [ value ]
    else
        # create the required dataset such that it
        # can be expanded indefinitely
        data = d_create(node, name, typeof(value), ((1,),(-1,)), "chunk", (50,))
        # write new entry as the first element of the arrays
        data[1] = [ value ]
    end
end
