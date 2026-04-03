Input = require("input")
Map = require("map")
Fov = require("fov")
Scheduler = require("scheduler")
Actor = require("actor")

width, height, flags = love.window.getMode()
timer = 0
grid = {}
queue = {}
gameOver = false

-- Best approach: Read-only table with unique table references
local function Enum(tbl)
    local enum = {}
    for _, v in ipairs(tbl) do
        enum[v] = {} -- Using empty tables ensures unique values
    end
    return setmetatable(enum, {
        __newindex = function() error("Enum is read-only", 2) end,
        __index = function(_, k) error("Key " .. tostring(k) .. " does not exist", 2) end
    })
end

local GameStates = Enum({"TARGETING", "SIMULATING", "WAITING", "GAMEOVER"})

-- Usage
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
    
    --all actors perform actions in list
    --there must be a delay between actions and actions don't start until player inputs commands
    --when any object moves it must update it's position in the grid
    --when any object moves it must check if its target is empty
    if(currentGameState ~= GameStates.GAMEOVER) then
        if(currentGameState == GameStates.WAITING) then --if we haven't moved then we can move immediately
            --move or don't move
            --init direction
            local direction = {}
            direction.x = 0
            direction.y = 0

            --find direction from keyboard

            --arrow keys
            local keypressed = false
            --lower 3 keys
            if Input.wasActionPressed("moveSouthwest") then
                direction.x = -1
                direction.y = 1
                keypressed = true
            end
            if Input.wasActionPressed("moveSouth") then
                direction.x = 0
                direction.y = 1
                keypressed = true
            end
            if Input.wasActionPressed("moveSoutheast") then
                direction.x = 1
                direction.y = 1
                keypressed = true
            end
            --middle 3 keys
            if Input.wasActionPressed("moveWest") then
                direction.x = -1
                direction.y = 0
                keypressed = true
            end
            if Input.wasActionPressed("wait") then
                direction.x = 0
                direction.y = 0
                keypressed = true
            end
            if Input.wasActionPressed("moveEast") then
                direction.x = 1
                direction.y = 0
                keypressed = true
            end
            --upper 3 keys
            if Input.wasActionPressed("moveNorthwest") then
                direction.x = -1
                direction.y = -1
                keypressed = true
            end
            if Input.wasActionPressed("moveNorth") then
                direction.x = 0
                direction.y = -1
                keypressed = true
            end
            if Input.wasActionPressed("moveNortheast") then
                direction.x = 1
                direction.y = -1
                keypressed = true
            end

            local isTryingMove = keypressed
            
            if(isTryingMove) then
                if(map:move(player, direction)) then
                    currentGameState = GameStates.SIMULATING
                end
            end
            if(currentGameState == GameStates.SIMULATING) then
                timer = 0.1
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
                        currentGameState = GameStates.WAITING
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
            end
        elseif timer > 0 then --if we have moved then we wait
            timer = timer - dt
        else --if we finished waiting reset the timer and say we haven't moved so you can move again
            timer = 0
            currentGameState = GameStates.WAITING
        end
        Input.update() --update input states each frame    
    end
    
end

function love.draw()
    --draw all objects in list at position xy
    map:draw()
end





