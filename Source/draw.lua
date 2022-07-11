draw = {}

local function drawGraph()

    local dotsize = 1       -- radius
    local topx = 200
    local topy = 50
    local graphheight = 75
    local bottomy = topy + graphheight
    local bottomx = topx

    local memorylength = 100    -- how many dots
    local graphlength = memorylength * dotsize

    love.graphics.setColor(1,1,1,1)
    love.graphics.line(topx,topy,bottomx,bottomy,bottomx + graphlength, bottomy)

    local maxindex = math.min(memorylength, #GRAPH)
    for i = 1, maxindex do
        local entitysum = GRAPH[i][1] + GRAPH[i][2] + GRAPH[i][3] + GRAPH[i][4] + GRAPH[i][5]

        local drawx = topx + (i * dotsize)
        local percent1 = GRAPH[i][1] / entitysum
        local significance = percent1 * graphheight * 3
        drawy = bottomy - significance
        love.graphics.setColor(0,1,0,1)
        love.graphics.circle("fill", drawx, drawy, dotsize)

        local percent2 = GRAPH[i][2] / entitysum
        local significance = percent2 * graphheight * 3
        drawy = bottomy - significance
        love.graphics.setColor(0,0,1,1)
        love.graphics.circle("fill", drawx, drawy, dotsize)

        local percent3 = GRAPH[i][3] / entitysum
        local significance = percent3 * graphheight * 3
        drawy = bottomy - significance
        love.graphics.setColor(1,0,0,1)
        love.graphics.circle("fill", drawx, drawy, dotsize)

        local percent4 = GRAPH[i][4] / entitysum
        local significance = percent4 * graphheight * 3
        drawy = bottomy - significance
        love.graphics.setColor(1,1,0,1)                             -- yellow
        love.graphics.circle("fill", drawx, drawy, dotsize)

        local percent5 = GRAPH[i][5] / entitysum
        local significance = percent5 * graphheight * 3
        drawy = bottomy - significance
        love.graphics.setColor(1,0,1,1)                             -- purple
        love.graphics.circle("fill", drawx, drawy, dotsize)

    end
end


function draw.HUD()

    local drawx = SCREEN_WIDTH - SIDEBAR_WIDTH
    local drawy = 0
    local drawwidth = SIDEBAR_WIDTH
    local drawheight = SCREEN_HEIGHT

    love.graphics.setColor(174/255, 174/255, 174/255, 0.8)
    love.graphics.rectangle("fill", drawx, drawy, drawwidth, drawheight)

    if VESSELS_SELECTED == 1 then
        -- draw things on sidebar

        local drawx = DISH_WIDTH + 10
        local drawy = 10

        love.graphics.setColor(1,1,1,1)

        love.graphics.print("Energy: " .. cf.round(SELECTED_VESSEL.position.energy, 0), drawx, drawy)
        drawy = drawy + 15

        love.graphics.print("Age: " .. cf.round(SELECTED_VESSEL.age.value, 0), drawx, drawy)
        drawy = drawy + 15

        if SELECTED_VESSEL:has("motion") then
            if SELECTED_VESSEL.motion.currentNoiseDistance ~= nil then
                love.graphics.print("Noise made: " .. cf.round(SELECTED_VESSEL.motion.currentNoiseDistance,0), drawx, drawy)
                drawy = drawy + 15
            end

            love.graphics.print("Current state: " .. cf.round(SELECTED_VESSEL.motion.currentState,0), drawx, drawy)
            drawy = drawy + 15
        end
    end

    drawGraph()
end


return draw
