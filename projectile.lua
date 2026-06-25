local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(x, y, directionX, directionY, damage, range, owner)
    local self = setmetatable({}, Projectile)
    self.x = x
    self.y = y
    self.directionX = directionX or 0
    self.directionY = directionY or 0
    self.damage = damage
    self.range = range
    self.distanceTraveled = 0
    self.owner = owner  -- to know who fired it
    return self
end

function Projectile:update(map)
    -- Move projectile
    self.x = self.x + self.directionX
    self.y = self.y + self.directionY
    self.distanceTraveled = self.distanceTraveled + 1
    
    -- Check if out of bounds
    if not map:isInBounds(self.x, self.y) then
        return true  -- mark for removal
    end
    
    -- Check if reached max range
    if self.distanceTraveled >= self.range then
        return true
    end
    
    -- Check collision with walls/obstacles
    if map:isSolid(self.x, self.y) then
        return true
    end
    
    -- Check collision with actors
    local hit = map:getActorAt(self.x, self.y)
    if hit and hit ~= self.owner then
        -- Deal damage to the hit actor
        hit.stats.hp = hit.stats.hp - self.damage
        print(self.owner.type .. "'s projectile hit " .. hit.type .. " for " .. self.damage .. " damage. " .. hit.type .. " has " .. hit.stats.hp .. " hp left.")
        if hit.stats.hp <= 0 then
            print(hit.type .. " has died.")
            map.grid[hit.x][hit.y].object = {type = "empty"}
        end
        return true  -- projectile consumed
    end
    
    return false  -- still alive
end

function Projectile:draw(cellWidth, cellHeight)
    love.graphics.setColor(1, 1, 0)  -- yellow
    love.graphics.circle("fill", 
        self.x * cellWidth + cellWidth/2, 
        self.y * cellHeight + cellHeight/2, 
        4)
end

return Projectile
