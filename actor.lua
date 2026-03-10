local Actor = {}

Actor.__index = Actor

function Actor.new(x, y, id, basestasts, map)
    local newActor = {}
    setmetatable(newActor, Actor)
    newActor.x = x
    newActor.y = y
    newActor.stats = basestasts
    newActor.map = map
    return newActor
end

function Actor:attack(attacker, target)
    if(target.id == "player" or target.id == "enemy") then
        target.hp = target.hp - attacker.attack
        print(attacker.id .. " attacked " .. target.id .. " for " .. attacker.attack .. " damage. " .. target.id .. " has " .. target.hp .. " hp left.")
        if(target.hp <= 0) then
            print(target.id .. " has died.")
            self.map.grid[target.x][target.y].object = {id = "empty"}-- you should make a function for this in map, like map:removeObject(target)
        end
    end
end

function Actor:gethp()
    return self.stats.hp
end

return Actor