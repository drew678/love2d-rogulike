local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(x, y, directionX, directionY, speed, damage, range, owner)
    local self = setmetatable({}, Projectile)
    self.x = x
    self.y = y
    self.directionX = directionX or 0
    self.directionY = directionY or 0
    self.speed = speed or 1
    self.damage = damage
    self.range = range
    self.distanceTraveled = 0
    self.owner = owner  -- to know who fired it
    return self
end

local function sign(num)
    if num > 0 then
        return 1
    elseif num < 0 then
        return -1
    else
        return 0
    end
end

function Projectile:update(map, dt)
    --we might need to add time so we can shrink the projectile speed based on time
    --we also need to add miss radius and accuracy and dodge
    local multiplier = self.speed/math.sqrt(math.pow(self.directionX, 2) + math.pow(self.directionY, 2))
    self.x = self.x + sign(self.directionX)*self.directionX*multiplier*dt
    self.y = self.y + sign(self.directionY)*self.directionY*multiplier*dt
    self.distanceTraveled = self.distanceTraveled + self.speed*dt
    
    -- Check if out of bounds
    if not map:isInBounds(self.x, self.y) then
        return true  -- mark for removal
    end

    print("distance traveled: " .. self.distanceTraveled .. "  / range: " .. tostring(self.range))
    
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
        hit.takeDamage(self.damage)
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
