local Input = {}

-- Table to track key states
Input.keysDown = {}
Input.keysPressed = {}
Input.keysReleased = {}

function love.keypressed(key, scancode, isrepeat)
    Input.keypressed(key)
end

function love.keyreleased(key, scancode)
    Input.keyreleased(key)
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
    -- Movement: numpad and vi keys
    moveNorth = {"up", "kp8"},
    moveSouth = {"down", "kp2"},
    moveWest = {"left", "kp4"},
    moveEast = {"right", "kp6"},
    moveNorthwest = {"kp7"},
    moveNortheast = {"kp9"},
    moveSouthwest = {"kp1"},
    moveSoutheast = {"kp3"},
    wait = {"kp5", ".", "clear"}, -- wait/skip turn
    -- Actions
    look = {"l"},
    pickup = {",", "g"},
    inventory = {"i"},
    attack = {"a"},
    descend = {">"},
    ascend = {"<"},
    help = {"?"},
    quit = {"escape", "q"},
}

function Input.isActionDown(action)
    for _, key in ipairs(Input.actions[action] or {}) do
        if Input.isDown(key) then return true end
    end
    return false
end

function Input.wasActionPressed(action)
    for _, key in ipairs(Input.actions[action] or {}) do
        if Input.wasPressed(key) then return true end
    end
    return false
end

function Input.wasActionReleased(action)
    for _, key in ipairs(Input.actions[action] or {}) do
        if Input.wasReleased(key) then return true end
    end
    return false
end

return Input