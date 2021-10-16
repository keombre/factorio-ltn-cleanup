local config = {}

function config.get_ltn(name)
    return settings.global["ltn-dispatcher-" .. name].value
end

function config.get_me(name)
    return settings.global["ltn-cleanup-" .. name].value
end

function config.stop_timeout()
    return config.get_ltn("stop-timeout(s)") * 60
end

function config.failed_trains()
    return config.get_me("failed-trains")
end

function config.min_fuel()
    return config.get_me("min-fuel-value")
end

function config.depot_inactivity()
    return config.get_ltn("depot-inactivity(s)") * 60
end

return config
