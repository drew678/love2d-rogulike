local Ability = {}

Ability.__index = Ability

function Ability.new(name, timeCost, manaCost)
    local self = setmetatable({}, Ability)
    self.name = name
    self.timeCost = timeCost
    self.manaCost = manaCost
    return self
end

function Ability:keypress(actor, target)
    if(actor.stats.mana >= self.manaCost) then
        actor.stats.mana = actor.stats.mana - self.manaCost
        return true
    else
        print("Not enough mana to use " .. self.name)
        return false
    end

end

function Ability:getCost()
    return self.timeCost
end

function Ability:getTimeCost()
    return self.timeCost
end

return Ability