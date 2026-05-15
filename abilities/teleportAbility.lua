Ability = require("ability")
Map = require("map")

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

function TeleportAbility:keypress(actor, target)
    if(Ability.keypress(self, actor, target)) then
        if(actor.map:isInBounds(target.x, target.y) and actor.map.grid[target.x][target.y].object.type == "empty") then
            actor.map:Basicmove(actor, target)
        else
            print("Invalid teleport location")
        end
    end
end

return TeleportAbility
