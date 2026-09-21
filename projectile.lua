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
    self.mapx = math.ceil(self.x - 0.5)
    self.mapy = math.ceil(self.y - 0.5)
    return self
end

function Projectile:getTarget(map)
    local a = self.directionY/self.directionX
    local b = -1
    local c = self.y - a*self.x
    local length = math.sqrt(math.pow(self.directionX, 2) + math.pow(self.directionY, 2))
    local ax = a/length
    local bx = b/length
    local cx = c/length
    local traveled = 0
    local xStop = self.x + self.directionX * self.range
    local yStop = self.y + self.directionY * self.range
    local curSquareX = math.floor(self.x)
    local curSquareY = math.floor(self.y)
    local prevSquareX = curSquareX
    local prevSquareY = curSquareY
    while(math.abs(curSquareX - self.x) < math.abs(xStop-self.x) and math.abs(curSquareY - self.y) < math.abs(yStop-self.y)) do
        local minDistance = math.huge

        for ix = -1, 1, 1 do
            for iy = -1, 1, 1 do
                if(ix == 0 and iy == 0) then
                    goto continue
                end
                local checkX = curSquareX + ix
                local checkY = curSquareY + iy
                if checkX == prevSquareX and checkY == prevSquareY then
                    goto continue
                end
                local dist = math.abs(ax*checkX + bx*checkY + cx)
                if(dist < minDistance) then
                  
                end
                ::continue::
            end
        end
    end
    while(traveled < self.range) do
        local nextX = self.x + ax
        local nextY = self.y + bx
        traveled = traveled + 1
        if(math.floor(nextX) ~= math.floor(self.x) or math.floor(nextY) ~= math.floor(self.y)) then
            return {x = math.floor(nextX), y = math.floor(nextY)}
        end
    end

end

function Projectile:update(map)
    --we might need to add time so we can shrink the projectile speed based on time
    --we also need to add miss radius and accuracy and dodge
    local checksPerTile = 10
    local multiplier = self.speed/math.sqrt(math.pow(self.directionX, 2) + math.pow(self.directionY, 2))/checksPerTile
    local xSpeed = self.directionX*multiplier
    local ySpeed = self.directionY*multiplier
    self.x = self.x + xSpeed
    self.y = self.y + ySpeed
    self.distanceTraveled = self.distanceTraveled + (self.speed/checksPerTile)
    self.mapx = math.ceil(self.x -0.5)
    self.mapy = math.ceil(self.y -0.5)

    -- Check collision with actors
    local hit = map:getActorAt(self.mapx, self.mapy)
    if hit and hit ~= self.owner then
        -- Deal damage to the hit actor
        hit:takeDamage(self.damage)
        print(self.owner.type .. "'s projectile hit " .. hit.type .. " for " .. self.damage .. " damage. " .. hit.type .. " has " .. hit.hp .. " hp left.")
        if hit.hp <= 0 then
            print(hit.type .. " has died.")
            map.grid[hit.x][hit.y].object = {type = "empty"}
        end
        print("Projectile hit " .. hit.type .. " at (" .. self.x .. ", " .. self.y .. ")")
        return true  -- projectile consumed
    end
    

    -- Check if out of bounds
    if not map:isInBounds(self.mapx, self.mapy) then
        print("Projectile went out of bounds at (" .. self.x .. ", " .. self.y .. ")")
        return true  -- mark for removal
    end
    
    -- Check if reached max range
    if self.distanceTraveled >= self.range then
        print("Projectile reached max range at (" .. self.x .. ", " .. self.y .. ")")
        return true
    end
    
    -- Check collision with walls/obstacles
    if map:isSolid(self.mapx, self.mapy) and map.grid[self.mapx][self.mapy].object ~= self.owner then
        print("Projectile hit a wall at (" .. self.x .. ", " .. self.y .. ")")
        return true
    end
    
    
    return false  -- still alive
end

function Projectile:draw(cellWidth, cellHeight)
    
    love.graphics.setColor(1, 1, 0)  -- yellow
    love.graphics.circle("fill", 
        self.x * cellWidth - cellWidth/2, 
        self.y * cellHeight - cellHeight/2, 
        4)
end

return Projectile
