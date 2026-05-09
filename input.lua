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
    if not Input.keysDown[key] then
        Input.num_down = Input.num_down + 1
    end
    Input.keysDown[key] = true
    Input.keysPressed[key] = true
end

-- Call this in love.keyreleased callback
function Input.keyreleased(key)
    if Input.keysDown[key] then
        Input.num_down = Input.num_down - 1
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

    -- NOTE!!!: The inner list (AND list) should never be empty, otherwise it will break the code that checks for actions, and it will be impossible to trigger the action.
    -- for example: {{"a",  "b"}, {}} is bad, because the second inner list is empty.

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
    teleport = {{"lshift", "t"}},
    abaction = {{"a"}, {"b"}}
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
        for _, t in ipairs(key) do
            if not Input.isDown(t) then
                all_down = false
                break
            end
        end
        if all_down then
                all_down = (#key == Input.num_down)
        end
        if all_down then return true end
    end
    return false
end

function Input.wasActionPressed(action)
    for _, key in ipairs(Input.actions[action] or {}) do
        local all_down = true
        local final_key = key[#key]
        local key_modifiers = {unpack(key, 1, #key - 1) or nil}
        for _, t in ipairs(key_modifiers) do
            if not Input.isDown(t) then
                all_down = false
                break
            end
        end
        if all_down then
            all_down = Input.wasPressed(final_key) and (#key == Input.num_down)
        end
        if all_down then return true end
    end
    return false
end

function Input.wasActionReleased(action)
    for _, key in ipairs(Input.actions[action] or {}) do
        local all_down = true
        local final_key = key[#key]
        local key_modifiers = {unpack(key, 1, #key - 1) or nil}
        for _, t in ipairs(key_modifiers) do
            if not Input.isDown(t) then
                all_down = false
                break
            end
        end
        if all_down then
            -- key was just released so the number of keys down should be one less than the number of keys in the action
            all_down = Input.wasReleased(final_key) and (#key - 1 == Input.num_down)
        end
        if all_down then return true end
    end
    return false
end

return Input