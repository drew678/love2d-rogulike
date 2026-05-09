Ability = require("ability")

ParentMeta = {}
ParentMeta.__index = Ability

TeleportAbility = {}
setmetatable(TeleportAbility, ParentMeta)

TAMeta = {}
TAMeta.__index = TeleportAbility

function TeleportAbility.new()
    local self = Ability.new("Teleport",100,100)
    setmetatable(self, TAMeta)

    return self
end

return TeleportAbility
