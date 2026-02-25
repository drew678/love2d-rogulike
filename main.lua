input = require("input")
map = require("map")

width, height, flags = love.window.getMode()
timer = 0
grid = {}
hasMoved = false
queue = {}
--actor queue
local function swap(t, a, b)
    t[a], t[b] = t[b], t[a]
end

function push(queue, time, actor)
    table.insert(queue, {time, actor})
    local i = #queue

    while i > 1 do
        local parent = math.floor(i/2)
        if queue[parent][1] <= queue[i][1] then break end
        swap(queue, parent, i)
        i = parent
    end
end

function pop(queue)
    if #queue == 0 then return nil end

    swap(queue, 1, #queue)
    local item = table.remove(queue)

    local i = 1
    while true do
        local left = i*2
        local right = left+1
        local smallest = i

        if queue[left] and queue[left][1] < queue[smallest][1] then smallest = left end
        if queue[right] and queue[right][1] < queue[smallest][1] then smallest = right end
        if smallest == i then break end

        swap(queue, i, smallest)
        i = smallest
    end

    return item[1], item[2]
end

function schedule(queue, actor, currentTime, cost)
    local speedFactor = 100 / actor.speed
    local nextTime = currentTime + cost * speedFactor
    push(queue, nextTime, actor)
end

--there are 2 different coordinate systems in game
--pixels on screen
--grid positions

function love.load()
    --we got to get all biome information/enemy information perks setup here
    --we need saving and load done

    --grid init
    num_rows = 25
    num_cols = 25
    row_length = width/num_cols
    col_length = height/num_rows
    
    --generation algos
    --generateEmptyMap()
    generateForestMap()

    --player init
    player = {x = 10, y = 10, id = "player", speed = 100}
    schedule(queue, player, 0, 100)
    grid[10][10].object = player.id
    computeFOV(player.x, player.y, 5)
end

function love.update(dt)
    
    --all actors perform actions in list
    --there must be a delay between actions and actions don't start until player inputs commands
    --when any object moves it must update it's position in the grid
    --when any object moves it must check if its target is empty

    if(not hasMoved) then --if we haven't moved then we can move immediately
        --move or don't move
        --init direction
        local direction = {}
        direction.x = 0
        direction.y = 0

        --find direction from keyboard

        --arrow keys
        local keypressed = false
        --lower 3 keys
        if input.wasActionPressed("moveSouthwest") then
            direction.x = -1
            direction.y = 1
            keypressed = true
        end
        if input.wasActionPressed("moveSouth") then
            direction.x = 0
            direction.y = 1
            keypressed = true
        end
        if input.wasActionPressed("moveSoutheast") then
            direction.x = 1
            direction.y = 1
            keypressed = true
        end
        --middle 3 keys
        if input.wasActionPressed("moveWest") then
            direction.x = -1
            direction.y = 0
            keypressed = true
        end
        if input.wasActionPressed("wait") then
            direction.x = 0
            direction.y = 0
            keypressed = true
        end
        if input.wasActionPressed("moveEast") then
            direction.x = 1
            direction.y = 0
            keypressed = true
        end
        --upper 3 keys
        if input.wasActionPressed("moveNorthwest") then
            direction.x = -1
            direction.y = -1
            keypressed = true
        end
        if input.wasActionPressed("moveNorth") then
            direction.x = 0
            direction.y = -1
            keypressed = true
        end
        if input.wasActionPressed("moveNortheast") then
            direction.x = 1
            direction.y = -1
            keypressed = true
        end


        local isTryingMove = keypressed
        
        if(isTryingMove) then
            hasMoved = move(player, direction)
        end
        if(hasMoved) then
            timer = 0.1
            --enemy movement
            --what is the direction of the player
            while true do
                local time, actor = pop(queue)
                if(actor.id ~= "player") then
                    local enemyDirection = {}
                    local deltax = player.x - actor.x
                    local deltay = player.y - actor.y
                    if(deltax > 0) then
                        enemyDirection.x = 1
                    elseif deltax == 0 then
                        enemyDirection.x = 0
                    else
                        enemyDirection.x = -1
                    end
                    if(deltay > 0) then
                        enemyDirection.y = 1
                    elseif deltay == 0 then
                        enemyDirection.y = 0
                    else
                        enemyDirection.y = -1
                    end
                    move(actor, enemyDirection)
                    schedule(queue, actor, time, 100)
                else
                    schedule(queue, actor, time, 100)
                    break
                end
            end
            resetVisiblity()
            computeFOV(player.x, player.y, 5)
        end
    elseif timer > 0 then --if we have moved then we wait
        timer = timer - dt
    else --if we finished waiting reset the timer and say we haven't moved so you can move again
        timer = 0
        hasMoved = false
    end
    input.update() --update input states each frame
end

function love.draw()
    --draw all objects in list at position xy
    love.graphics.circle("fill", gridCoordstoScreen(player.x, row_length), gridCoordstoScreen(player.y, col_length), math.min(row_length/2, col_length/2))--player
    for i = 1, num_cols do
        for j = 1, num_rows do
            if( grid[i][j].visibility == true) then
                if(grid[i][j].object == "tree") then
                    love.graphics.setColor({0,1,0})--walls
                    love.graphics.rectangle("fill", (i-1)*row_length, (j-1)*col_length, row_length, col_length)
                elseif(grid[i][j].object == "enemy") then
                    love.graphics.setColor({1,0,0})--enemies
                    love.graphics.circle("fill", gridCoordstoScreen(i, row_length), gridCoordstoScreen(j, col_length), math.min(row_length/2, col_length/2))
                end
            end
            
        end
    end
    love.graphics.setColor({1,1,1})
end

function gridCoordstoScreen(dimension, axis)
    return (dimension*axis) - axis/2
end

--doesn't work


function generateForestMap()
    --forest generation
    for i = 1, num_cols do
        grid[i] = {}
        for j = 1, num_rows do
            tile = {object = "empty", visibility = false}
            grid[i][j] = tile
            
            if(math.random() < 0.125) then
                grid[i][j].object = "tree"
            elseif(math.random() < 0.01) then
                local enemy = {x = i, y = j, id = "enemy", speed = 100}
                push(queue, 0, enemy)
                grid[i][j].object = "enemy"
            else
                grid[i][j].object = "empty"
            end
        end
    end
end


function move(mover, direction)
    local target = {} --target move location
    target.x = mover.x + direction.x
    target.y = mover.y + direction.y

    if(isInMap(target.x, target.y)) then --out of bounds check
        if(grid[target.x][target.y].object == "empty") then --empty space check
            grid[mover.x][mover.y].object = "empty" --move
            mover.x = target.x
            mover.y = target.y
            grid[mover.x][mover.y].object = mover.id
            return true
        else
            return false
        end
    else
        return false
    end
end

mult = {
    { 1, 0, 0, 1 },
    { 0, 1, 1, 0 },
    { 0, 1, -1, 0 },
    { -1, 0, 0, 1 },
    { -1, 0, 0, -1 },
    { 0, -1, -1, 0 },
    { 0, -1, 1, 0 },
    { 1, 0, 0, -1 }
}

function computeFOV(px, py, radius)
    setVisible(px, py)
    for oct = 1, 8 do
        castLight(px, py, 1, 1.0, 0.0, radius,
            mult[oct][1], mult[oct][2],
            mult[oct][3], mult[oct][4])
    end
end

function castLight(cx, cy, row, startSlope, endSlope, radius, xx, xy, yx, yy)
    if startSlope < endSlope then return end

    local radiusSquared = radius * radius

    for i = row, radius do
        local dx = -i - 1
        local dy = -i
        local blocked = false
        local newStart = startSlope

        while dx <= 0 do
            dx = dx + 1

            local X = cx + dx * xx + dy * xy
            local Y = cy + dx * yx + dy * yy

            local lSlope = (dx - 0.5) / (dy + 0.5)
            local rSlope = (dx + 0.5) / (dy - 0.5)

            if startSlope < rSlope then
                goto continue
            elseif endSlope > lSlope then
                break
            end

            if dx*dx + dy*dy <= radiusSquared then
                setVisible(X, Y)
            end

            if blocked then
                if isBlocked(X, Y) then
                    newStart = rSlope
                    goto continue
                else
                    blocked = false
                    startSlope = newStart
                end
            else
                if isBlocked(X, Y) and i < radius then
                    blocked = true
                    castLight(cx, cy, i+1, startSlope, lSlope,
                        radius, xx, xy, yx, yy)
                    newStart = rSlope
                end
            end

            ::continue::
        end

        if blocked then break end
    end
end

function isBlocked(x, y)
    if(not isInMap(x, y)) then
        return true
    end
    return grid[x][y].object == "tree"
end

function setVisible(x, y)
    if(not isInMap(x, y)) then
        return
    end
    grid[x][y].visibility = true
end

function isInMap(x, y)
    return x > 0 and x <= num_cols and y > 0 and y <= num_rows
end

function resetVisiblity()
    for i = 1, num_cols do
        for j = 1, num_rows do
            grid[i][j].visibility = false
        end
    end
end