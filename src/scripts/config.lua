local config = {}

function config.get_ltn(name)
    return settings.global["ltn-dispatcher-" .. name].value
end

function config.stop_timeout()
    return config.get_ltn("stop-timeout(s)") * 60
end

return config
