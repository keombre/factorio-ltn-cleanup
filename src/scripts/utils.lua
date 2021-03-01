local utils = {}

function utils.build_reverse_index(values)
    local index = {}
    for k, v in pairs(values) do
        index[v] = k
    end
    return index
end

return utils
