local json = require ("dkjson")

local Stats = {}

Stats.__index = Stats

function Stats.new(id)
    local newStats = {}
    setmetatable(newStats, Stats)
    newStats.id = id
    local file = io.open("game_data/basestats.json", "r")
    if(not file) then
        error("Stats file not found")
    end
    local contents = file:read("*a")
    local data = json.decode(contents)
    newStats.maxHp = data[id].maxHp
    newStats.attack = data[id].attack
    newStats.speed = data[id].speed

    return newStats
end

function Stats:applyVariation()
    local lower = 0.8
    local upper = 1.2
    self.maxHp = math.random(self.maxHp*lower , self.maxHp*upper)
    self.hp = self.maxHp
    self.attack = math.random(self.attack*lower , self.attack*upper)
    self.speed = math.random(self.speed*lower , self.speed*upper)
end

return Stats