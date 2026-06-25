local Ability = require("abilities/ability")
local FireballAbility = setmetatable({}, {__index = Ability})
FireballAbility.__index = FireballAbility

function FireballAbility.new()
    local self = setmetatable({}, FireballAbility)
    self.name = "fireball"
    local data = self:initFromJson()
    self.damage = data[self.name].damage
    self.range = data[self.name].range
    return self
end

function FireballAbility:activate(actor, targetPos, map)
    if not self:canUse(actor) then
        print("Not enough mana to use " .. self.name)
        return false
    end

    -- Calculate direction from actor to target
    local dx = targetPos.x - actor.x
    local dy = targetPos.y - actor.y
    
    -- Normalize direction
    local dirX = 0
    local dirY = 0
    
    if dx > 0 then dirX = 1 elseif dx < 0 then dirX = -1 end
    if dy > 0 then dirY = 1 elseif dy < 0 then dirY = -1 end
    
    if dirX == 0 and dirY == 0 then
        print("Cannot cast fireball at own position")
        return false
    end
    
    self:payCost(actor)
    self.cooldownRemaining = self.cooldown
    
    -- Create and add projectile
    local Projectile = require("projectile")
    table.insert(projectiles, Projectile.new(actor.x, actor.y, dirX, dirY, self.damage, self.range, actor))
    
    print(actor.type .. " cast " .. self.name .. " in direction (" .. dirX .. ", " .. dirY .. ")")
    return true
end

return FireballAbility
