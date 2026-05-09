local Input = {}
loveli = require("LOVELi")

-- Table to track key states
Input.keysDown = {}
Input.keysPressed = {}
Input.keysReleased = {}
Input.num_down = 0
Input.num_pressed = 0
Input.num_released = 0
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
    if not Input.keysDown[key] then
        Input.num_down = Input.num_down + 1
    end
    if not Input.keypressed[key] then
        Input.num_pressed = Input.num_pressed + 1
    end
    Input.keysDown[key] = true
    Input.keysPressed[key] = true
end

-- Call this in love.keyreleased callback
function Input.keyreleased(key)
    if Input.keysDown[key] then
        Input.num_down = Input.num_down - 1
    end
    if Input.keysReleased[key] then
        Input.num_released = Input.num_released + 1
    end
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

    --format: { {a,b,c}, {d,e,f}, {g, h ,i} } 
    -- means keys a, b, and c pressed together can trigger the action, OR keys d and e and f can also trigger the action,
    -- OR keys g, h, and i can also trigger the action

    -- Movement: numpad and vi keys
    moveNorth = {{"up"}, {"kp8"}},
    moveSouth = {{"down"}, {"kp2"}},
    moveWest = {{"left"}, {"kp4"}},
    moveEast = {{"right"}, {"kp6"}},
    moveNorthwest = {{"kp7"}},
    moveNortheast = {{"kp9"}},
    moveSouthwest = {{"kp1"}},
    moveSoutheast = {{"kp3"}},
    wait = {{"kp5"}, {"."}, {"clear"}}, -- wait/skip turn
    -- Actions
    look = {{"l"}},
    pickup = {{",", "g"}},
    inventory = {{"i"}},
    attack = {{"a"}},
    descend = {{">"}},
    ascend = {{"<"}},
    help = {{"?"}},
    quit = {{"escape"}, {"q"}},
    -- this is where we assign keys to actions, we can add more actions and keys as needed
    -- Abilities
    teleport = {{"shift", "t"}},
}

-- I don't understand this function, what does it do?
function Input.getActions()
    for _, key in ipairs(Input.actions[action] or {}) do -- this returns the list of keys for the action, or an empty table if the action isn't defined
        if Input.isDown(key) then return true end
    end
end

function Input.isActionDown(action)
    for _, key in ipairs(Input.actions[action] or {}) do -- this returns the list of keys for the action, or an empty table if the action isn't defined
        local all_down = true
        for t in key do
            if not Input.isDown(t) then
                all_down = false
                break
            end
        end
        if all_down then return true end
    end
    return false
end

function Input.wasActionPressed(action)
    for _, key in ipairs(Input.actions[action] or {}) do
        local all_pressed = true
        for t in key do
            if not Input.wasPressed(t) then
                all_pressed = false
                break
            end
        end
        if all_pressed then return true end
    end
    return false
end

function Input.wasActionReleased(action)
    for _, key in ipairs(Input.actions[action] or {}) do
        local all_released = true
        for t in key do
            if not Input.wasReleased(t) then
                all_released = false
                break
            end
        end
        if all_released then return true end
    end
    return false
end

return Input