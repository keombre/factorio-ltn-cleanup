local format = {}

function format.debug(msg)
    game.print(serpent.line(msg))
end

function format.all(msg)
    game.print("[color=yellow][LTN Cleanup][/color] " .. msg)
end

function format.item(name)
    return "[item=" .. name .. "]"
end

function format.fluid(name)
    return "[fluid=" .. name .. "]"
end

function format.train(train)
    if #train.locomotives.front_movers == 0 and #train.locomotives.back_movers == 0 then
        return "Train " .. train.id
    elseif #train.locomotives.back_movers == 0 then
        return "[train=" .. train.locomotives.front_movers[1].unit_number .. "]"
    else
        return "[train=" .. train.locomotives.back_movers[1].unit_number .. "]"
    end
end

function format.warning(msg)
    format.all("[color=#ffa500]Warning:[/color] " .. msg .. "")
end

function format.alert(msg)
    format.all("[color=#ff2b1f]Alert:[/color] " .. msg .. "")
end

function format.info(msg)
    format.all("[color=#008b8b]Info:[/color] " .. msg .. "")
end

function format.train_depot_alert(train)
    format.alert("Train " .. format.train(train) .. " will arrive at depot with remaining cargo")
end

function format.show_fatal(error, msg)
    if game.is_multiplayer() then
        game.print("[color=red][LTN Cleanup Error] Unexpected error occured.[/color] [color=orange]Error: " .. serpent.line(error) .. "[/color]\n" .. msg)
    else
        game.show_message_dialog{text="[font=default-large-bold]LTN Cleanup[/font][font=default-bold] - Unexpected error occured[/font]\n\n[color=orange]Error: " .. error .. "[/color]\n\n" .. msg .. "\n To continue press: "}
    end
end

return format
