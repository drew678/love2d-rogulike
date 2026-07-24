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
        target:takeDamage(self.stats.attack)
    end
end

function Actor:takeDamage(amount)
    self.stats.hp = self.stats.hp - amount
    print(self.type .. " took " .. amount .. " damage. Current HP: " .. self.stats.hp)
    if self.stats.hp <= 0 then
        print(self.type .. " has died.")
        self.map.grid[self.x][self.y].object = {type = "empty"}
    end
end

function Actor:gethp()
    return self.stats.hp
end

return Actor