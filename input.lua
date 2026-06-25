local Input = {}
loveli = require("LOVELi")

-- Table to track key states
Input.keysDown = {}
Input.keysPressed = {}
Input.keysReleased = {}
Input.num_down = 0
--these are hooks to get the input to work and get keyboard presses
function love.keypressed(key, scancode, isrepeat)
    Input.keypressed(key)
    layoutmanager:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    Input.keyreleased(key)
end

function love.textinput(text)
    layoutmanager:textinput(text)
end

function love.mousepressed(x, y, button, istouch, presses)
    layoutmanager:mousepressed(x, y, button, istouch, presses)
end
function love.mousereleased(x, y, button, istouch, presses)
    layoutmanager:mousereleased(x, y, button, istouch, presses)
end
function love.mousemoved(x, y, dx, dy, istouch)
    layoutmanager:mousemoved(x, y, dx, dy, istouch)
end
function love.wheelmoved(dx, dy)
    layoutmanager:wheelmoved(dx, dy)
end
function love.joystickhat(joystick, hat, direction)
    layoutmanager:joystickhat(joystick, hat, direction)
end
function love.joystickpressed(joystick, button)
    layoutmanager:joystickpressed(joystick, button)
end

-- Call this in love.keypressed callback
function Input.keypressed(key)
    Input.keysDown[key] = true
    Input.keysPressed[key] = true
end

-- Call this in love.keyreleased callback
function Input.keyreleased(key)
    Input.keysDown[key] = false
    Input.keysReleased[key] = true
end

-- Call this once per frame to clear pressed/released states
function Input.update()
    Input.keysPressed = {}
    Input.keysReleased = {}
end

-- Utility functions
function Input.isDown(key)
    return Input.keysDown[key] or false
end

function Input.wasPressed(key)
    return Input.keysPressed[key] or false
end

function Input.wasReleased(key)
    return Input.keysReleased[key] or false
end

-- Example: map actions to keys
Input.actions = {
    --
    moveNowhere = {},
    moveNorth = {"up", "kp8"},
    moveSouth = {"down", "kp2"},
    moveWest = {"left", "kp4"},
    moveEast = {"right", "kp6"},
    moveNorthwest = {"kp7"},
    moveNortheast = {"kp9"},
    moveSouthwest = {"kp1"},
    moveSoutheast = {"kp3"},
    wait = {"kp5", {"."}, {"clear"}}, -- wait/skip turn
    -- Actions
    look = {"l"},
    confirm = {"return"},
    pickup = {",", "g"},
    inventory = {"i"},
    attack = {"a"},
    descend = {">"},
    ascend = {"<"},
    help = {"?"},
    quit = {"escape", "q"},
    -- this is where we assign keys to actions, we can add more actions and keys as needed
    teleport = {"t"},
    fireball = {"f"},
}

function Input.addAction(action, keys)
    Input.actions[action] = keys
end

function Input.wasActionPressed(action)
    for _, key in ipairs(Input.actions[action] or {}) do
        if(type(key) == "table") then
            local keyDown = true
            for _, v in ipairs(key) do
                if not Input.wasPressed(v) then
                    keyDown = false
                end
            end
            if(keyDown) then
                return true
            end
        elseif(type(key) == "string") then
            if(Input.wasPressed(key)) then
                return true
            end
        end
    end
    return false
end

function Input.wasActionReleased(action)
    for _, key in ipairs(Input.actions[action] or {}) do
        if(type(key) == "table") then
            local keyDown = true
            for _, v in ipairs(key) do
                if not Input.wasReleased(v) then
                    keyDown = false
                end
            end
            if(keyDown) then
                return true
            end
        elseif(type(key) == "string") then
            if(Input.wasReleased(key)) then
                return true
            end
        end
    end
    return false
end

return Input