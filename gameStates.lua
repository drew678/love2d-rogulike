local function Enum(tbl)
    local enum = {}
    for _, v in ipairs(tbl) do
        enum[v] = {} -- Using empty tables ensures unique values
    end
    return setmetatable(enum, {
        __newindex = function() error("Enum is read-only", 2) end,
        __index = function(_, k) error("Key " .. tostring(k) .. " does not exist", 2) end
    })
end

local GameStates = Enum({"TARGETING", "SIMULATING", "WAITING", "GAMEOVER", "INVENTORY", "DELAY"})

return GameStates