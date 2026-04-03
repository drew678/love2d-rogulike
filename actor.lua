local Actor = {}
local Stats = require("stats")

Actor.__index = Actor

function Actor.new(x, y, id, type, map)
    local newActor = {}
    setmetatable(newActor, Actor)
    newActor.x = x
    newActor.y = y
    newActor.type = type
    newActor.stats = Stats.new(type)
    newActor.id = id
    newActor.map = map
    return newActor
end

function Actor:attack(target)
    if((self.type == "player" and target.type == "enemy") or (self.type == "enemy" and target.type == "player")) then --allegiance check
        target.stats.hp = target.stats.hp - self.stats.attack-- change this to a take damage function
        print(self.type .. " attacked " .. target.type .. " for " .. self.stats.attack .. " damage. " .. target.type .. " has " .. target.stats.hp .. " hp left.")
        if(target.stats.hp <= 0) then
            print(target.type .. " has died.")
            self.map.grid[target.x][target.y].object = {type = "empty"}-- you should make a function for this in map, like map:removeObject(target)
        end
    end
end

function Actor:gethp()
    return self.stats.hp
end

return Actor