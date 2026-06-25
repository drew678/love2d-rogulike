local Map = {}
local Scheduler = require("scheduler")
local Actor = require("actor")
local GameStates = require("gameStates")

Map.__index = Map

function Map.new(num_rows, num_cols, row_length, col_length)
    local newMap = {}
    setmetatable(newMap, Map)
    newMap.grid = {}
    newMap.num_rows = num_rows
    newMap.num_cols = num_cols
    newMap.row_length = row_length
    newMap.col_length = col_length
    newMap.target = {x = 0, y = 0, targeting = false}
    return newMap
end

function Map:setTarget(target)
    self.target.x = target.x
    self.target.y = target.y
    self.target.targeting = true
end

function Map:moveTarget(direction)
    if(self:isInBounds(self.target.x + direction.x, self.target.y + direction.y)) then
        self.target.x = self.target.x + direction.x
        self.target.y = self.target.y + direction.y
    end
end

function Map:removeTarget()
    self.target.x = 0
    self.target.y = 0
    self.target.targeting = false
end

--doesn't work
function Map:generateEmptyMap()
    --desert/empty
    for i = 1, self.num_cols do
        self.grid[i] = {}
        for j = 1, self.num_rows do
            self.grid[i][j] = {object = {type = "empty"}, visibility = "unseen"}
        end
    end
end

function Map:generateForestMap()
    --forest generation
    for i = 1, self.num_cols do
        self.grid[i] = {}
        for j = 1, self.num_rows do
            local tile = {object = {type = "empty"}, visibility = "unseen"}
            self.grid[i][j] = tile
            
            if(math.random() < 0.125) then
                self.grid[i][j].object = {type = "tree"}
            elseif(math.random() < 0.01) then
                local enemy = Actor.new(i, j, "enemy", "enemy", self)
                Scheduler:push(0, enemy)
                self.grid[i][j].object = enemy
            else
                self.grid[i][j].object = {type = "empty"}
            end
        end
    end
end

function Map:addObject(object)
    local x = object.x
    local y = object.y
    if(self:isInBounds(x, y)) then
        self.grid[x][y].object = object
    else
        error("Attempted to add object out of bounds")
    end
end

function Map:move(mover, target)
    if(self:isInBounds(target.x, target.y)) then --out of bounds check
        if(self.grid[target.x][target.y].object.type == "empty") then --empty space check
            self:basicMove(mover, target)
            return true
        else
            mover:attack(self.grid[target.x][target.y].object) --attack
            return true
        end
    else
        return false
    end
end

function Map:basicMove(mover, target)
    -- assert(self:isInBounds(target.x, target.y), "Attempted to move to out of bounds location")
    -- assert(self.grid[target.x][target.y].object.type == "empty", "Attempted to move to non-empty location")
    self.grid[mover.x][mover.y].object = {type = "empty"}
    mover.x = target.x
    mover.y = target.y
    self.grid[mover.x][mover.y].object = mover
end

function Map:isBlocked(x, y)
    if(not self:isInBounds(x, y)) then
        return true
    end
    return self.grid[x][y].object.type == "tree"
end

function Map:setVisible(x, y)
    if(not self:isInBounds(x, y)) then
        return
    end
    self.grid[x][y].visibility = "seeing"
end

function Map:isInBounds(x, y)
    return x > 0 and x <= self.num_cols and y > 0 and y <= self.num_rows
end

function Map:resetVisibility()
    for i = 1, self.num_cols do
        for j = 1, self.num_rows do
            if( self.grid[i][j].visibility == "seeing") then
                self.grid[i][j].visibility = "seen"
            end
        end
    end
end

function Map:getrandomEmptyCell()
    local x, y, counter = 0, 0, 0
    x = math.random(1, self.num_cols)
    y = math.random(1, self.num_rows)
    for i = 1, self.num_cols do
        for j = 1, self.num_rows do
            local xi = (x + i -1) % (self.num_cols + 1)
            local yj = (y + j -1) % (self.num_rows + 1)
            if(self.grid[xi][yj].object.type == "empty") then
                return xi, yj, true
            end
        end
    end
    return x, y, false
end

local function gridCoordstoScreen(dimension, axis)
    return (dimension*axis) - axis/2
end

function Map:draw()
    for i = 1, self.num_cols do
        for j = 1, self.num_rows do
            if(self.grid[i][j].visibility == "seeing") then
                if(self.grid[i][j].object.type == "tree") then
                    love.graphics.setColor({0,1,0})--walls
                    love.graphics.rectangle("fill", (i-1)*self.row_length, (j-1)*self.col_length, self.row_length, self.col_length)
                elseif(self.grid[i][j].object.type == "enemy") then
                    love.graphics.setColor({1,0,0})--enemies
                    love.graphics.circle("fill", gridCoordstoScreen(i, self.row_length), gridCoordstoScreen(j, self.col_length), math.min(self.row_length/2, self.col_length/2))
                elseif(self.grid[i][j].object.type == "player") then
                    love.graphics.setColor({1,1,1})--player
                    love.graphics.circle("fill", gridCoordstoScreen(i, self.row_length), gridCoordstoScreen(j, self.col_length), math.min(self.row_length/2, self.col_length/2))--player
                end
            elseif(self.grid[i][j].visibility == "seen") then
                if(self.grid[i][j].object.type == "tree") then
                    love.graphics.setColor({0,0.5,0})--seen walls
                    love.graphics.rectangle("fill", (i-1)*self.row_length, (j-1)*self.col_length, self.row_length, self.col_length)
                end
            end
            if(self.target.targeting and self.target.x == i and self.target.y == j) then
                love.graphics.setColor({1,1,1})--targeting
                love.graphics.rectangle("fill", (i-1)*self.row_length, (j-1)*self.col_length, self.row_length/5, self.col_length/10)
                love.graphics.rectangle("fill", (i-1)*self.row_length, (j-1)*self.col_length, self.row_length/10, self.col_length/5)

                love.graphics.rectangle("fill", (i)*self.row_length - self.row_length/5, (j-1)*self.col_length, self.row_length/5, self.col_length/10)
                love.graphics.rectangle("fill", (i)*self.row_length - self.row_length/10, (j-1)*self.col_length, self.row_length/10, self.col_length/5)

                love.graphics.rectangle("fill", (i-1)*self.row_length, (j)*self.col_length - self.col_length/10, self.row_length/5, self.col_length/10)
                love.graphics.rectangle("fill", (i-1)*self.row_length, (j)*self.col_length - self.col_length/5, self.row_length/10, self.col_length/5)

                love.graphics.rectangle("fill", (i)*self.row_length - self.row_length/5, (j)*self.col_length - self.col_length/10, self.row_length/5, self.col_length/10)
                love.graphics.rectangle("fill", (i)*self.row_length - self.row_length/10, (j)*self.col_length - self.col_length/5, self.row_length/10, self.col_length/5)
            end
        end
    end
    love.graphics.setColor({1,1,1})
end

function Map:isSolid(x, y)
    if not self:isInBounds(x, y) then
        return true
    end
    local obj = self.grid[x][y].object
    return obj.type == "tree" or obj.type == "enemy" or obj.type == "player"
end

function Map:getActorAt(x, y)
    if not self:isInBounds(x, y) then
        return nil
    end
    local obj = self.grid[x][y].object
    if obj.type == "enemy" or obj.type == "player" then
        return obj
    end
    return nil
end

return Map