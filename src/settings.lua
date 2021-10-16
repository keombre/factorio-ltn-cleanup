data:extend({
    {
        type = "bool-setting",
        name = "ltn-cleanup-failed-trains",
        setting_type = "runtime-global",
        default_value = false
    },
    {
        type = "int-setting",
        name = "ltn-cleanup-min-fuel-value",
        setting_type = "runtime-global",
        minimum_value = 0,
        maximum_value = 1000,
        default_value = 360,
    },
})
