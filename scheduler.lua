Scheduler = {}

Scheduler.queue = {}

-- function Scheduler.new()
--     local newScheduler = {}
--     setmetatable(newScheduler, self)
--     newScheduler.queue = {}
--     return newScheduler
-- end

local function swap(t, a, b)
    t[a], t[b] = t[b], t[a]
end

function Scheduler:push(time, actor)
    table.insert(self.queue, {time, actor})
    local i = #self.queue

    while i > 1 do
        local parent = math.floor(i/2)
        if self.queue[parent][1] <= self.queue[i][1] then break end
        swap(self.queue, parent, i)
        i = parent
    end
end

function Scheduler:pop()
    if #self.queue == 0 then return nil end

    swap(self.queue, 1, #self.queue)
    local item = table.remove(self.queue)

    local i = 1
    while true do
        local left = i*2
        local right = left+1
        local smallest = i

        if self.queue[left] and self.queue[left][1] < self.queue[smallest][1] then smallest = left end
        if self.queue[right] and self.queue[right][1] < self.queue[smallest][1] then smallest = right end
        if smallest == i then break end

        swap(self.queue, i, smallest)
        i = smallest
    end

    return item[1], item[2]
end

function Scheduler:schedule(actor, currentTime, cost)
    local speedFactor = 100 / actor.speed
    local nextTime = currentTime + cost * speedFactor
    self:push(nextTime, actor)
end

return Scheduler