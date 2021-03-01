local format = require("format")
local train_stops = {}

function train_stops.parse_name(name)
    local list = {
        generic_item = false,
        items = {},
        fluids = {}
    }

    for word in string.gmatch(name, "%b[]") do
        if word == "[virtual-signal=ltn-item-cleanup-station]" then
            list.generic_item = true
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

function train_stops.is_cleanup(name)
    if name ~= nil and string.find(name, "%[virtual%-signal=ltn%-cleanup%-station%]") then
        return true
    end
    return false
end

function train_stops.get_all_cleanup()
    local stops = {}

    for _, stop in pairs(game.get_train_stops()) do
        if train_stops.is_cleanup(stop.backer_name) then
            local processes = train_stops.parse_name(stop.backer_name)
            table.insert(stops, {
                id = stop.unit_number,
                name = stop.backer_name,
                process = processes
            })
        end
    end

    return stops
end

function train_stops.find_generic_item(stops)
    local generic = {}
    for _, stop in pairs(stops) do
        if stop.process.generic_item then
            table.insert(generic, stop)
        end
    end
    if #generic ~= 0 then
        return generic[math.random(#generic)]
    end
end

function train_stops.find_item(stops, item)
    for _, stop in pairs(stops) do
        for _, f_item in pairs(stop.process.items) do
            if f_item == item then
                return stop
            end
        end
    end
end

function train_stops.find_fluid(stops, fluid)
    for _, stop in pairs(stops) do
        for _, f_fluid in pairs(stop.process.fluids) do
            if f_fluid == fluid then
                return stop
            end
        end
    end
end

return train_stops
