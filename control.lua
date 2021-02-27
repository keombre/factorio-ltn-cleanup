function PrintAll(msg)
    for _, player in pairs(game.players) do
        player.print("[color=green][LTN Cleanup][/color] " .. msg)
    end
end

function PrintItem(name)
    return "[item=" .. name .. "]"
end

function PrintFluid(name)
    return "[fluid=" .. name .. "]"
end

function PrintWarning(msg)
    PrintAll("[color=#ffa500][font=default-large-bold]Warning![/font][/color] [font=default-large]" .. msg .. "[/font]")
end

function PrintAlert(msg)
    PrintAll("[color=#ca0b00][font=default-large-bold]Alert![/font][/color] [font=default-large]" .. msg .. "[/font]")
end

function PrintInfo(msg)
    PrintAll("[color=#0023d4][font=default-large-bold]Info[/font][/color] [font=default-large]" .. msg .. "[/font]")
end

function PrintTrainDepotWarning(train)
    PrintAlert("Train " .. train.id .. " will arrive at depot with remaining cargo")
end

function ParseStationName(name)
    local list = {genericItem = false, items = {}, fluids = {}}

    for word in string.gmatch(name, "%b[]") do
        if word == "[virtual-signal=ltn-item-cleanup-station]" then
            list.genericItem = true
        else
            local item = string.match(word, "item=(.+)]")
            if item ~= nil then
                table.insert(list.items, item)
            else
                local fluid = string.match(word, "fluid=(.+)]")
                if fluid ~= nil then
                    table.insert(list.fluids, fluid)
                end
            end
        end
    end

    return list
end

function GetAllCleanupStations()
    local stations = {}

    for _, station in pairs(game.get_train_stops()) do
        if string.find(station.backer_name, "%[virtual%-signal=ltn%-cleanup%-station%]") then
            local processes = ParseStationName(station.backer_name)
            table.insert(stations, {name = station.backer_name, process = processes})
        end
    end

    return stations
end

function GetAllTrash(train)
    local trash = {items = {}, fluids = {}}

    for item, ammount in pairs(train.get_contents()) do
        table.insert(trash.items, item)
    end

    for fluid, ammount in pairs(train.get_fluid_contents()) do
        table.insert(trash.fluids, fluid)
    end

    return trash
end

function BuildRecord(station, wait_for)
    local record = {station = station.name, wait_conditions = {}}

    for _, item in pairs(wait_for.items) do
        table.insert(record.wait_conditions, {type = "item_count", condition = {first_signal = {type = "item", name = item}, comparator = "=", constant = 0}, compare_type = "and"})
    end

    for _, fluid in pairs(wait_for.fluids) do
        table.insert(record.wait_conditions, {type = "fluid_count", condition = {first_signal = {type = "fluid", name = fluid}, comparator = "=", constant = 0}, compare_type = "and"})
    end

    local timeout = settings.global["ltn-dispatcher-stop-timeout(s)"].value * 60
    table.insert(record.wait_conditions, {type = "time", compare_type = "or", ticks = timeout})
    return record
end

function FindGenericItemStation(stations)
    local generic = {}
    for _, station in pairs(stations) do
        if station.process.genericItem then
            table.insert(generic, station)
        end
    end
    if #generic ~= 0 then
        return generic[math.random(#generic)]
    end
end

function FindItemStation(stations, item)
    for _, station in pairs(stations) do
        for _, f_item in pairs(station.process.items) do
            if f_item == item then
                return station
            end
        end
    end
end

function FindFluidStation(stations, fluid)
    for _, station in pairs(stations) do
        for _, f_fluid in pairs(station.process.fluids) do
            if f_fluid == fluid then
                return station
            end
        end
    end
end

function BuildReverseIndex(values)
    local index = {}
    for k, v in pairs(values) do
        index[v] = k
    end
    return index
end

function ProcessAny(station_process, values)
    local index = BuildReverseIndex(values)
    local wait = {}

    for _, val in pairs(station_process) do
        local ind = index[val]
        if ind ~= nil then
            table.insert(wait, val)
            table.remove(values, ind)
            index = BuildReverseIndex(values)
        end
    end

    return {wait = wait, values = values}
end

function ProcessStation(trash, station)
    if station == nil then
        return
    end

    local wait = {items = {}, fluids = {}}

    local items_resp = ProcessAny(station.process.items, trash.items)
    trash.items = items_resp.values
    wait.items = items_resp.wait

    local fluids_resp = ProcessAny(station.process.fluids, trash.fluids)
    trash.fluids = fluids_resp.values
    wait.fluids = fluids_resp.wait

    return {wait = wait, trash = trash}
end

function BuildSchedule(train)
    local trash = GetAllTrash(train)

    if #trash.items == 0 and #trash.fluids == 0 then
        PrintInfo("LTN marked empty train " .. train.id .. " with remaining cargo. Skipping...")
        return
    end

    local stations = GetAllCleanupStations()

    if #stations == 0 then
        PrintWarning("No cleanup stations found")
        PrintTrainDepotWarning(train)
        return
    end

    local schedule = {}
    local needs_generic = {}

    while #trash.items > 0 do
        local item_station = FindItemStation(stations, trash.items[1])
        if item_station == nil then
            table.insert(needs_generic, trash.items[1])
            table.remove(trash.items, 1)
        else
            local item_resp = ProcessStation(trash, item_station)
            trash = item_resp.trash
            table.insert(schedule, BuildRecord(item_station, item_resp.wait))
        end
    end

    while #trash.fluids > 0 do
        local fluid_station = FindFluidStation(stations, trash.fluids[1])
        if fluid_station == nil then
            PrintWarning("No cleanup stations to process " .. PrintFluid(trash.fluids[1]) .. " found")
            PrintTrainDepotWarning(train)
            return
        else
            local fluid_resp = ProcessStation(trash, fluid_station)
            trash = fluid_resp.trash
            table.insert(schedule, BuildRecord(fluid_station, fluid_resp.wait))
        end
    end

    if #needs_generic > 0 then
        local generic_station = FindGenericItemStation(stations)

        if generic_station == nil then
            local items = ""
            for _, item in pairs(needs_generic) do
                items = items .. " " .. PrintItem(item)
            end
            PrintWarning("No generic cleanup stations found to process " .. items)
            PrintTrainDepotWarning(train)
            return
        end

        table.insert(schedule, BuildRecord(generic_station, {items = needs_generic, fluids = {}}))
    end

    return schedule
end

function OnRequesterRemainingCargo(event)
    local train = event.train

    local records = BuildSchedule(train)
    if records == nil or #records == 0 then
        return
    end

    PrintInfo("Cleaning train " .. train.id)

    local schedule = train.schedule
    local curr = #train.schedule.records + 1

    for _, record in pairs(records) do
        table.insert(schedule.records, record)
    end

    schedule.current = curr
    train.schedule = schedule
end

function RegisterCallback()
    if remote.interfaces["logistic-train-network"] then
        script.on_event(remote.call("logistic-train-network", "on_requester_remaining_cargo"), OnRequesterRemainingCargo)
    end
end

script.on_load(RegisterCallback)
script.on_init(RegisterCallback)
