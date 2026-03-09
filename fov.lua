Fov = {}

mult = {
    { 1, 0, 0, 1 },
    { 0, 1, 1, 0 },
    { 0, 1, -1, 0 },
    { -1, 0, 0, 1 },
    { -1, 0, 0, -1 },
    { 0, -1, -1, 0 },
    { 0, -1, 1, 0 },
    { 1, 0, 0, -1 }
}

function Fov.computeFOV(map, px, py, radius)
    map:setVisible(px, py)
    for oct = 1, 8 do
        Fov.castLight(map, px, py, 1, 1.0, 0.0, radius,
            mult[oct][1], mult[oct][2],
            mult[oct][3], mult[oct][4])
    end
end

function Fov.castLight(map, cx, cy, row, startSlope, endSlope, radius, xx, xy, yx, yy)
    if startSlope < endSlope then return end

    local radiusSquared = radius * radius

    for i = row, radius do
        local dx = -i - 1
        local dy = -i
        local blocked = false
        local newStart = startSlope

        while dx <= 0 do
            dx = dx + 1

            local X = cx + dx * xx + dy * xy
            local Y = cy + dx * yx + dy * yy

            local lSlope = (dx - 0.5) / (dy + 0.5)
            local rSlope = (dx + 0.5) / (dy - 0.5)

            if startSlope < rSlope then
                goto continue
            elseif endSlope > lSlope then
                break
            end

            if dx*dx + dy*dy <= radiusSquared then
                map:setVisible(X, Y)
            end

            if blocked then
                if map:isBlocked(X, Y) then
                    newStart = rSlope
                    goto continue
                else
                    blocked = false
                    startSlope = newStart
                end
            else
                if map:isBlocked(X, Y) and i < radius then
                    blocked = true
                    Fov.castLight(map, cx, cy, i+1, startSlope, lSlope,
                        radius, xx, xy, yx, yy)
                    newStart = rSlope
                end
            end

            ::continue::
        end

        if blocked then break end
    end
end

return Fov