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
    newActor.abilities = {}
    newActor.lastRegenTime = 0
    newActor:addAbility("teleport", TeleportAbility.new()) 
    return newActor
end

function Actor:addAbility(name, ability)
    self.abilities[name] = ability
end

function Actor:hasAbility(name)
    return self.abilities[name] ~= nil
end

function Actor:getAbility(name)
    return self.abilities[name]
end

function Actor:regenerate(time)
    print(self.type .. " regenerating. Current HP: " .. self.stats.hp .. ", Current Mana: " .. self.stats.mana)
    local timeElapsed = time - self.lastRegenTime
    self.stats.mana = math.min(self.stats.mana + self.stats.manaRegen *timeElapsed, self.stats.maxMana)
    self.stats.hp = math.min(self.stats.hp + self.stats.healthRegen *timeElapsed, self.stats.maxHp)
    self.lastRegenTime = time
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