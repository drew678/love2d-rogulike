Input = require("input")
Map = require("map")
Fov = require("fov")
Scheduler = require("scheduler")
Actor = require("actor")
GameStates = require("gameStates")
width, height, flags = love.window.getMode()
timer = 0
grid = {}
queue = {}
gameOver = false

local currentGameState = GameStates.WAITING

--there are 2 different coordinate systems in game
--pixels on screen
--grid positions

function love.load()
    --we got to get all biome information/enemy information perks setup here
    --we need saving and load done=
    
    --grid init
    local num_rows = 25
    local num_cols = 25
    local row_length = width/num_cols
    local col_length = height/num_rows
    
    --generation algos
    --generateEmptyMap()
    map = Map.new(num_rows, num_cols, row_length, col_length)
    map:generateForestMap()

    --player init
    player = Actor.new(0, 0, "player", "player", map)
    Scheduler:schedule(player, 0, player.stats.speed)
    local x, y, found = map:getrandomEmptyCell()
    if(not found) then
        error("No empty cell found for player")
    end
    player.x = x
    player.y = y
    map:addObject(player)
    Fov.computeFOV(map, player.x, player.y, 5)
end

function love.update(dt)
    if currentGameState == GameStates.WAITING then
        local isTryingMove = false
        local direction = {}
        isTryingMove, direction = getMovementInput()
        
        if Input.wasActionPressed("look") and not isTryingMove then
            currentGameState = GameStates.TARGETING
            map:setTarget({x = player.x, y = player.y})
        end

        if isTryingMove then
            if(map:move(player, direction)) then
                currentGameState = GameStates.SIMULATING
            end
        end
    elseif currentGameState == GameStates.TARGETING then
        local isTryingMove = false
        local direction = {}
        isTryingMove, direction = getMovementInput()
        if isTryingMove then
            map:moveTarget(direction)
            isTryingMove = false
        end
        if(Input.wasActionPressed("quit")) then
            currentGameState = GameStates.WAITING
            map:removeTarget()
        end
    elseif currentGameState == GameStates.SIMULATING then
        --simulate all actors until we get back to the player
        while true do
            local time, actor = Scheduler:pop()
            if(actor.type ~= "player") then
                if(actor.stats.hp <= 0) then
                    goto continue
                end
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
                map:move(actor, enemyDirection)
                Scheduler:schedule(actor, time+100, actor.stats.speed) --we need to change that 100 to be based on action cost
            else
                currentGameState = GameStates.DELAY
                if(actor.stats.hp <= 0) then
                    currentGameState = GameStates.GAMEOVER
                    print("Game Over!")
                end
                Scheduler:schedule(actor, time+100, actor.stats.speed)
                break
            end
            ::continue::
        end
        map:resetVisibility()
        Fov.computeFOV(map, player.x, player.y, 10)
    elseif currentGameState == GameStates.DELAY then
        timer = timer + dt
        if timer >= .1 then
            timer = 0
            currentGameState = GameStates.WAITING
        end
    end
    Input.update()
end

-- function love.update(dt)
    
--     --all actors perform actions in list
--     --there must be a delay between actions and actions don't start until player inputs commands
--     --when any object moves it must update it's position in the grid
--     --when any object moves it must check if its target is empty
--     if(currentGameState == GameStates.WAITING) then
--         --check for input
--         local isTryingMove = false
--         local direction = {}
--         isTryingMove, direction = getMovementInput()

--         if Input.wasActionPressed("look") then
--             if(not isTryingMove) then
--                 currentGameState = GameStates.TARGETING
--             end
--         end
        
--         if(isTryingMove and  currentGameState ~= GameStates.TARGETING) then
--             if(map:move(player, direction)) then
--                 currentGameState = GameStates.SIMULATING
--             end
--         end

--         --moves to another game state if we have input
--         if(currentGameState == GameStates.TARGETING) then
--             target = {x = player.x, y = player.y}
--             map:setTarget({x = player.x + direction.x, y = player.y + direction.y})
            
--         end
--         if(currentGameState == GameStates.SIMULATING) then
--             --simulate all actors until we get back to the player
--             while true do
--                 local time, actor = Scheduler:pop()
--                 if(actor.type ~= "player") then
--                     if(actor.stats.hp <= 0) then
--                         goto continue
--                     end
--                     local enemyDirection = {}
--                     local deltax = player.x - actor.x
--                     local deltay = player.y - actor.y
--                     if(deltax > 0) then
--                         enemyDirection.x = 1
--                     elseif deltax == 0 then
--                         enemyDirection.x = 0
--                     else
--                         enemyDirection.x = -1
--                     end
--                     if(deltay > 0) then
--                         enemyDirection.y = 1
--                     elseif deltay == 0 then
--                         enemyDirection.y = 0
--                     else
--                         enemyDirection.y = -1
--                     end
--                     map:move(actor, enemyDirection)
--                     Scheduler:schedule(actor, time+100, actor.stats.speed) --we need to change that 100 to be based on action cost
--                 else
--                     currentGameState = GameStates.WAITING
--                     if(actor.stats.hp <= 0) then
--                         currentGameState = GameStates.GAMEOVER
--                         print("Game Over!")
--                     end
--                     Scheduler:schedule(actor, time+100, actor.stats.speed)
--                     break
--                 end
--                 ::continue::
--             end
--             map:resetVisibility()
--             Fov.computeFOV(map, player.x, player.y, 10)
--         end
--     end
--     Input.update() --update input states each frame        
-- end

function getMovementInput()
    local isTryingMove = false
    local direction = {}
    direction.x = 0
    direction.y = 0
    --lower 3 keys
    if Input.wasActionPressed("moveSouthwest") then
        direction.x = -1
        direction.y = 1
        isTryingMove = true
    end
    if Input.wasActionPressed("moveSouth") then
        direction.x = 0
        direction.y = 1
        isTryingMove = true
    end
    if Input.wasActionPressed("moveSoutheast") then
        direction.x = 1
        direction.y = 1
        isTryingMove = true
    end
    --middle 3 keys
    if Input.wasActionPressed("moveWest") then
        direction.x = -1
        direction.y = 0
        isTryingMove = true
    end
    if Input.wasActionPressed("wait") then
        direction.x = 0
        direction.y = 0
        isTryingMove = true
    end
    if Input.wasActionPressed("moveEast") then
        direction.x = 1
        direction.y = 0
        isTryingMove = true
    end
    --upper 3 keys
    if Input.wasActionPressed("moveNorthwest") then
        direction.x = -1
        direction.y = -1
        isTryingMove = true
    end
    if Input.wasActionPressed("moveNorth") then
        direction.x = 0
        direction.y = -1
        isTryingMove = true
    end
    if Input.wasActionPressed("moveNortheast") then
        direction.x = 1
        direction.y = -1
        isTryingMove = true
    end
    return isTryingMove, direction
end

function love.draw()
    --draw all objects in list at position xy
    map:draw()
    if(currentGameState == GameStates.TARGETING) then
        --love.graphics.setColor({1,0,0})
        --love.graphics.rectangle("line", gridCoordstoScreen(map.col_length, targeting.x), gridCoordstoScreen(map.row_length, targeting.y), map.col_length, map.row_length)
    end
end