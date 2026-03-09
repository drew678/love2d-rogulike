local Map = {}
local Scheduler = require("scheduler")

Map.__index = Map

function Map.new(num_rows, num_cols, row_length, col_length)
    local newMap = {}
    setmetatable(newMap, Map)
    newMap.grid = {}
    newMap.num_rows = num_rows
    newMap.num_cols = num_cols
    newMap.row_length = row_length
    newMap.col_length = col_length

    return newMap
end

--doesn't work
function Map:generateEmptyMap()
    --desert/empty
    for i = 1, num_cols do
        self.grid[i] = {}
        for j = 1, num_rows do
            self.grid[i][j].object = {id = "empty"}
        end
    end
end

function Map:generateForestMap()
    --forest generation
    for i = 1, self.num_cols do
        self.grid[i] = {}
        for j = 1, self.num_rows do
            local tile = {object = {id = "empty"}, visibility = false}
            self.grid[i][j] = tile
            
            if(math.random() < 0.125) then
                self.grid[i][j].object = {id = "tree"}
            elseif(math.random() < 0.01) then
                local enemy = {x = i, y = j, id = "enemy", speed = 100, hp = 10, attack = 1}
                Scheduler:push(0, enemy)
                self.grid[i][j].object = enemy
            else
                self.grid[i][j].object = {id = "empty"}
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


function Map:move(mover, direction)
    local target = {} --target move location
    target.x = mover.x + direction.x
    target.y = mover.y + direction.y

    if(self:isInBounds(target.x, target.y)) then --out of bounds check
        if(self.grid[target.x][target.y].object.id == "empty") then --empty space check
            self.grid[mover.x][mover.y].object = {id = "empty"}
            mover.x = target.x
            mover.y = target.y
            self.grid[mover.x][mover.y].object = mover
            return true
        else
            self:attack(mover, self.grid[target.x][target.y].object) --attack
            return true
        end
    else
        return false
    end
end

function Map:attack(attacker, target)
    if(target.id == "player" or target.id == "enemy") then
        target.hp = target.hp - attacker.attack
        print(attacker.id .. " attacked " .. target.id .. " for " .. attacker.attack .. " damage. " .. target.id .. " has " .. target.hp .. " hp left.")
        if(target.hp <= 0) then
            print(target.id .. " has died.")
            self.grid[target.x][target.y].object = {id = "empty"}
        end
    end
end

function Map:isBlocked(x, y)
    if(not self:isInBounds(x, y)) then
        return true
    end
    return self.grid[x][y].object.id == "tree"
end

function Map:setVisible(x, y)
    if(not self:isInBounds(x, y)) then
        return
    end
    self.grid[x][y].visibility = true
end

function Map:isInBounds(x, y)
    return x > 0 and x <= self.num_cols and y > 0 and y <= self.num_rows
end

function Map:resetVisibility()
    for i = 1, self.num_cols do
        for j = 1, self.num_rows do
            self.grid[i][j].visibility = false
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
            if(self.grid[xi][yj].object.id == "empty") then
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
            if(self.grid[i][j].visibility == true) then
                if(self.grid[i][j].object.id == "tree") then
                    love.graphics.setColor({0,1,0})--walls
                    love.graphics.rectangle("fill", (i-1)*self.row_length, (j-1)*self.col_length, self.row_length, self.col_length)
                elseif(self.grid[i][j].object.id == "enemy") then
                    love.graphics.setColor({1,0,0})--enemies
                    love.graphics.circle("fill", gridCoordstoScreen(i, self.row_length), gridCoordstoScreen(j, self.col_length), math.min(self.row_length/2, self.col_length/2))
                elseif(self.grid[i][j].object.id == "player") then
                    love.graphics.setColor({1,1,1})--player
                    love.graphics.circle("fill", gridCoordstoScreen(i, self.row_length), gridCoordstoScreen(j, self.col_length), math.min(self.row_length/2, self.col_length/2))--player
                end
            end
        end
    end
    love.graphics.setColor({1,1,1})
end

return Map