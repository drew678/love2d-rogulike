Ability = require("ability")

ParentMeta = {}
ParentMeta.__index = Ability

TeleportAbility = {}
setmetatable(TeleportAbility, ParentMeta)

TAMeta = {}
TAMeta.__index = TeleportAbility

function TeleportAbility.new()
    local self = {}
    setmetatable(self, TAMeta)

    self.cost = 2
    return self
end

return TeleportAbility




local ta = TeleportAbility.new()

ta.getCost()