local Ability = {}

Ability.__index = Ability

function Ability.new(name, timeCost, manaCost)
    local self = setmetatable({}, Ability)
    self.name = name
    self.timeCost = timeCost
    self.manaCost = manaCost
    return self
end

function Ability:activate(actor)

end

function Ability:getCost()
    return self.timeCost
end

function Ability:getTimeCost()
    return self.timeCost
end

return Ability