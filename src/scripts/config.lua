local config = {}

function config.get_ltn(name)
    return settings.global[name].value
end

function config.stop_timeout()
    return config.get_ltn("ltn-dispatcher-stop-timeout(s)") * 60
end

return config
