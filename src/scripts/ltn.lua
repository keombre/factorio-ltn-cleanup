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

function ltn.is_carriage_in_limit(stop_id, carriages)
    if ltn.is_ltn_stop(stop_id) then
        local stop = global.last_ltn_update[stop_id]
        if stop.max_carriages == 0 then
            return carriages >= stop.min_carriages
        else
            return carriages <= stop.max_carriages and carriages >= stop.min_carriages
        end
    end
    return true
end

function ltn.lamp_color(stop_id, color)
    if ltn.is_ltn_stop(stop_id) then
        local stop = global.last_ltn_update[stop_id]
        if stop.lamp_control.valid then
            stop.lamp_control.get_control_behavior().parameters =
                {{
                    index = 1,
                    count = 1,
                    signal = {
                        type = "virtual",
                        name = color
                    }
                }}
        end
    end
end

function ltn.lamp_activate(stop_id)
    ltn.lamp_color(stop_id, "signal-pink")
end

function ltn.lamp_deactivate(stop_id)
    ltn.lamp_color(stop_id, "signal-white")
end

return ltn
