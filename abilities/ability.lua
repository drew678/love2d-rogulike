local Ability = {}
local json = require ("dkjson")


Ability.__index = Ability

function Ability:initFromJson()
    local game_files = love.filesystem.getSource( )
    local file_path = game_files .. "/" .. "game_data/abilities.json"
    local file = io.open(file_path)

    if(not file) then
        error("Stats file not found")
    end
    local contents = file:read("*a")
    file:close()
    local data = json.decode(contents)

    self.timeCost = data[self.name].timeCost
    self.manaCost = data[self.name].manaCost
    self.cooldown = data[self.name].cooldown
    self.targetType = data[self.name].targetType
    self.onCooldownUntil = 0
    return data
end

function Ability:canUse(actor, currentTime)
    if(actor.stats.mana < self.manaCost) then
        print(actor.type .. " does not have enough mana to use " .. self.name .. ". Required: " .. self.manaCost .. ", Available: " .. actor.stats.mana)
        return false
    elseif self.onCooldownUntil > currentTime then
        print(actor.type .. " is not ready to use " .. self.name .. " yet. Cooldown remaining: " .. (self.onCooldownUntil - currentTime))
        return false
    end
    return true
end

function Ability:use(actor, target, map, currentTime)
    if not self:canUse(actor, currentTime) then
        return false
    end
    actor.stats.mana = actor.stats.mana - self.manaCost
    self.onCooldownUntil = currentTime + self.cooldown
    return self:activate(actor, target, map)
end

function Ability:activate(actor, target, map)
    return false
end

function Ability:getCost()
    return self.manaCost
end

function Ability:getTimeCost()
    return self.timeCost
end

return Ability