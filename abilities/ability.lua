local Ability = {}

Ability.__index = Ability

function Ability.new(name, timeCost, manaCost, cooldown, targetType)
    local self = setmetatable({}, Ability)
    self.name = name
    self.timeCost = timeCost
    self.manaCost = manaCost
    self.cooldown = cooldown
    self.cooldownRemaining = 0
    self.targetType = targetType

    return self
end

function Ability:keypress(actor, target)
    return self:use(actor, target)
end

function Ability:canUse(actor)
    return actor.stats.mana >= self.manaCost and self.cooldownRemaining <= 0
end

function Ability:payCost(actor)
    actor.stats.mana = actor.stats.mana - self.manaCost
end

function Ability:use(actor, target)
    if not self:canUse(actor) then
        print("Not enough mana to use " .. self.name)
        return false
    end

    self:payCost(actor)
    self.cooldownRemaining = self.cooldown
    return self:activate(actor, target)
end

function Ability:activate(actor, target)
    return false
end

function Ability:getCost()
    return self.manaCost
end

function Ability:getTimeCost()
    return self.timeCost
end

return Ability