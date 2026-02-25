local Map = {}
local grid = {}
local num_rows = 25
local num_cols = 25

function Map.generateEmptyMap()
    --desert/empty
    for i = 1, num_cols do
        grid[i] = {}
        for j = 1, num_rows do
            grid[i][j] = "empty"
        end
    end
end

function Map.generateForestMap()
    --forest generation
    for i = 1, num_cols do
        grid[i] = {}
        for j = 1, num_rows do
            tile = {object = "empty", visibility = false}
            grid[i][j] = tile
            
            if(math.random() < 0.125) then
                grid[i][j].object = "tree"
            elseif(math.random() < 0.01) then
                local enemy = {x = i, y = j, id = "enemy", speed = 100}
                push(queue, 0, enemy)
                grid[i][j].object = "enemy"
            else
                grid[i][j].object = "empty"
            end
        end
    end
end

return Map