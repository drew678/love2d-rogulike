local Actor = {}
local Json = require ("dkjson")
local AbilityTable = {
    teleport = require("abilities/teleportAbility"),
    fireball = require("abilities/fireballAbility")
}

Actor.__index = Actor

function Actor.new(x, y, type, map)
    local newActor = {}
    setmetatable(newActor, Actor)
    newActor.x = x
    newActor.y = y
    newActor.type = type
    newActor.map = map
    newActor.abilities = {}
    newActor.lastRegenTime = 0

    local game_files = love.filesystem.getSource( )
    local file_path = game_files .. "/" .. "game_data/creatures.json"
    local file = io.open(file_path)

    if(not file) then
        error("Stats file not found")
    end
    local contents = file:read("*a")
    file:close()
    local data = Json.decode(contents)
    newActor.maxHp = data[type].maxHp
    newActor.hp = newActor.maxHp
    newActor.maxMana = data[type].maxMana
    newActor.mana = newActor.maxMana
    newActor.damage = data[type].damage
    newActor.speed = data[type].speed
    newActor.healthRegen = data[type].healthRegen
    newActor.manaRegen = data[type].manaRegen
    newActor.faction = data[type].faction
    newActor.color = data[type].color or {1, 1, 1} -- default to white if no color specified

    for i, abilityName in ipairs(data[type].abilities) do
        local Ability = AbilityTable[abilityName]
        newActor:addAbility(abilityName, Ability.new(ability))
    end

    return newActor
end

function Actor:addAbility(name, ability)
    self.abilities[name] = ability
end

function Actor:hasAbility(name)
    return self.abilities[name] ~= nil
end

function Actor:getAbility(name)
    return self.abilities[name]
end

function Actor:regenerate(time)
    print(self.type .. " regenerating. Current HP: " .. self.hp .. ", Current Mana: " .. self.mana)
    local timeElapsed = time - self.lastRegenTime
    self.mana = math.min(self.mana + self.manaRegen *timeElapsed, self.maxMana)
    self.hp = math.min(self.hp + self.healthRegen *timeElapsed, self.maxHp)
    self.lastRegenTime = time
end

function Actor:attack(target)
    if((self.faction == "player" and target.faction == "enemy") or (self.faction == "enemy" and target.faction == "player")) then --allegiance check
        target:takeDamage(self.damage)
    end
end

function Actor:takeDamage(amount)
    print(self)
    self.hp = self.hp - amount
    print(self.type .. " took " .. amount .. " damage. Current HP: " .. self.hp)
    if self.hp <= 0 then
        print(self.type .. " has died.")
        self.map.grid[self.x][self.y].object = {type = "empty"}
    end
end

-- function Stats:applyVariation()
--     local lower = 0.8
--     local upper = 1.2
--     self.maxHp = math.random(self.maxHp*lower , self.maxHp*upper)
--     self.hp = self.maxHp
--     self.maxMana = math.random(self.maxMana*lower , self.maxMana*upper)
--     self.mana = self.maxMana
--     self.attack = math.random(self.attack*lower , self.attack*upper)
--     self.speed = math.random(self.speed*lower , self.speed*upper)
-- end

local function gridCoordstoScreen(dimension, axis)
    return (dimension*axis) - axis/2
end

function Actor:draw(i, j, row_length, col_length)
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", gridCoordstoScreen(i, row_length), gridCoordstoScreen(j, col_length), math.min(row_length/2, col_length/2))
end





return Actor