function printAll(msg)
    for _, player in pairs(game.players) do
        player.print("[LTN Cleanup] " .. msg)
    end
end

function OnRequesterRemainingCargo(event)

    local train = event.train
    local fluids = {}

    for fluid, ammount in pairs(train.get_fluid_contents()) do
        table.insert(fluids, fluid)
    end

    -- load stations
    local stations = {}

    for _, station in pairs(game.get_train_stops()) do
        if string.find(station.backer_name, "%[virtual%-signal=ltn%-cleanup%-station%]") then
            table.insert(stations, station.backer_name)
        end
    end

    if #stations == 0 then
        printAll("No cleanup stations found")
        return
    end

    local target_station = nil

    if #fluids > 0 then
        if #fluids > 1 then
            printAll("Multiple fluids found in train " .. event.train .. ". Now processing " .. fluids[1])
        end

        for _, name in pairs(stations) do
            if string.find(name, "%[fluid=" .. string.gsub(fluids[1], "%-", "%%-") .. "%]") then
                target_station = name
                goto station_fluid_search_done
            end
        end
        ::station_fluid_search_done::

        if target_station == nil then
            printAll("No viable station found to process " .. fluids[1])
            return
        end
    else
        for _, name in pairs(stations) do
            if string.find(name, "%[virtual%-signal=ltn%-item%-cleanup%-station%]") then
                target_station = name
                goto station_item_search_done
            end
        end
        ::station_item_search_done::

        if target_station == nil then
            printAll("No viable station found to process items")
            return
        end
    end

    printAll("Sending train " .. train.id .. " to " .. target_station)

    local record = {station = target_station, wait_conditions = {{type = "empty", compare_type = "or"}, {type = "inactivity", compare_type = "or", ticks = 7200}}}

    local schedule = train.schedule
    table.insert(schedule.records, record)
    schedule.current = #schedule.records

    train.schedule = schedule
end

script.on_load(function(data)
    if remote.interfaces["logistic-train-network"] then
        script.on_event(remote.call("logistic-train-network", "on_requester_remaining_cargo"), OnRequesterRemainingCargo)
    end
end)
