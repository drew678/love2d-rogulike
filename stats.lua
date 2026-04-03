local json = require ("dkjson")

local Stats = {}

Stats.__index = Stats

function Stats.new(type)
    local newStats = {}
    setmetatable(newStats, Stats)

    game_files = love.filesystem.getSource( )
    file_path = game_files .. "/" .. "game_data/basestats.json"
    local file = io.open(file_path)

    if(not file) then
        error("Stats file not found")
    end
    contents = file:read("*a")
    file:close()
    local data = json.decode(contents)
    newStats.maxHp = data[type].maxHp
    newStats.hp = newStats.maxHp
    newStats.attack = data[type].attack
    newStats.speed = data[type].speed
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