local format = require("format")
local scheduler = require("scheduler")
local trains = require("trains")

local handler = {}

function handler.on_requester_remaining_cargo(event)
    local train = event.train

    if train.valid ~= true then
        return
    end

    if train.state == defines.train_state.manual_control or train.state == defines.train_state.manual_control_stop then
        format.warning("Ignoring manually controlled train " .. format.train(train))
        return
    end

    if train.schedule ~= nil and train.schedule.current ~= 1 then
        format.warning("Ignoring train " .. format.train(train) .. " after unexpected schedule alteration")
        return
    end

    if train.schedule == nil then
        format.warning("Train " .. format.train(train) .. " has empty schedule. Skipping...")
        return
    end

    local records = scheduler.build(train)
    if records == nil or #records == 0 then
        return
    end

    format.info("Cleaning train " .. format.train(train))

    trains.update_schedule(train, records)
end

function handler.on_stops_updated(event)
    -- format.debug(event)
end

function handler.on_train_changed_state(event)
    if event.old_state == defines.train_state.wait_station and trains.finished_cleaning(event.train) then
        format.train_depot_alert(event.train)
    end
end

function handler.register_callbacks()
    if remote.interfaces["logistic-train-network"] then
        script.on_event(remote.call("logistic-train-network", "on_requester_remaining_cargo"),
            handler.on_requester_remaining_cargo)
        script.on_event(remote.call("logistic-train-network", "on_stops_updated"), handler.on_stops_updated)
        script.on_event(defines.events.on_train_changed_state, handler.on_train_changed_state)
    end
end

return handler
