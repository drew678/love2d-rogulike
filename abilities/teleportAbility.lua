Ability = require("abilities/ability")
Map = require("map")

ParentMeta = {}
ParentMeta.__index = Ability

TeleportAbility = {}
setmetatable(TeleportAbility, ParentMeta)

TAMeta = {}
TAMeta.__index = TeleportAbility

function TeleportAbility.new()
    local self = setmetatable({}, TAMeta)
    self.name = "teleport"
    self:initFromJson()
    return self
end

function TeleportAbility:activate(actor, target, map)
    if not actor or not actor.map or not target then
        return false
    end

    if not actor.map:isInBounds(target.x, target.y) then
        print("Invalid teleport location")
        return false
    end

    if actor.map.grid[target.x][target.y].object.type ~= "empty" then
        print("Invalid teleport location")
        return false
    end

    map:basicMove(actor, target)
    return true
end

return TeleportAbility
