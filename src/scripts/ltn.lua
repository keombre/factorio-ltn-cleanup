local ltn = {}

function ltn.save_stop_update(logistic_train_stops)
    global.last_ltn_update = logistic_train_stops
end

function ltn.get_network(stop_id)
    if ltn.is_ltn_stop(stop_id) then
        return global.last_ltn_update[stop_id].network_id
    end
end

function ltn.is_ltn_stop(stop_id)
    return global.last_ltn_update[stop_id] ~= nil
end

return ltn
