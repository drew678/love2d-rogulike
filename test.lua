Test = {}
Input = require("input")

local teleport_down = false

function Test.testInput()
    if(Input.wasActionPressed("moveNowhere")) then
        print("Move nowhere action was just pressed.")
    end
    if (Input.isActionDown("teleport")) then
        if teleport_down == false then
            print("Teleport action is now being held down.")
            teleport_down = true
        end
        print("Teleport action is currently being held down.")
    else
        teleport_down = false
    end
    if (Input.wasActionPressed("teleport")) then
        print("Teleport action was just pressed.")
    end

    if (Input.wasActionReleased("teleport")) then
        print("Teleport action was just released.")
    end

    if (Input.wasActionPressed("abaction")) then
        print("A-B-action was just pressed.")
    end

    if (Input.wasActionReleased("abaction")) then
        print("A-B-action was just released.")
    end
end

return Test