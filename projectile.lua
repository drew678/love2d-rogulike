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

function Projectile:update(map)
    --we might need to add time so we can shrink the projectile speed based on time
    --we also need to add miss radius and accuracy and dodge
    local multiplier = self.speed/math.sqrt(math.pow(self.directionX, 2) + math.pow(self.directionY, 2))
    local xSpeed = self.directionX*multiplier
    local ySpeed = self.directionY*multiplier
    self.x = self.x + xSpeed
    self.y = self.y + ySpeed
    self.distanceTraveled = self.distanceTraveled + self.speed
    local mapx = math.ceil(self.x)
    local mapy = math.ceil(self.y)

    -- Check collision with actors
    local hit = map:getActorAt(mapx, mapy)
    if hit and hit ~= self.owner then
        -- Deal damage to the hit actor
        hit:takeDamage(self.damage)
        print(self.owner.type .. "'s projectile hit " .. hit.type .. " for " .. self.damage .. " damage. " .. hit.type .. " has " .. hit.stats.hp .. " hp left.")
        if hit.stats.hp <= 0 then
            print(hit.type .. " has died.")
            map.grid[hit.x][hit.y].object = {type = "empty"}
        end
        print("Projectile hit " .. hit.type .. " at (" .. self.x .. ", " .. self.y .. ")")
        return true  -- projectile consumed
    end
    

    -- Check if out of bounds
    if not map:isInBounds(mapx, mapy) then
        print("Projectile went out of bounds at (" .. self.x .. ", " .. self.y .. ")")
        return true  -- mark for removal
    end

    print("distance traveled: " .. self.distanceTraveled .. "  / range: " .. tostring(self.range))
    
    -- Check if reached max range
    if self.distanceTraveled >= self.range then
        print("Projectile reached max range at (" .. self.x .. ", " .. self.y .. ")")
        return true
    end
    
    -- Check collision with walls/obstacles
    if map:isSolid(mapx, mapy) and map.grid[mapx][mapy].object.type ~= "player" then
        print("Projectile hit a wall at (" .. self.x .. ", " .. self.y .. ")")
        return true
    end
    
    
    return false  -- still alive
end

function Projectile:draw(cellWidth, cellHeight)
    print("Drawing projectile at (" .. self.x .. ", " .. self.y .. ")")
    love.graphics.setColor(1, 1, 0)  -- yellow
    love.graphics.circle("fill", 
        self.x * cellWidth - cellWidth/2, 
        self.y * cellHeight - cellHeight/2, 
        4)
end

return Projectile
