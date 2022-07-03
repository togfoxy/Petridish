draw = {}

function draw.HUD()

    local drawx = SCREEN_WIDTH - SIDEBAR_WIDTH
    local drawy = 0
    local drawwidth = SIDEBAR_WIDTH
    local drawheight = SCREEN_HEIGHT

    love.graphics.setColor(174/255, 174/255, 174/255, 0.8)
    love.graphics.rectangle("fill", drawx, drawy, drawwidth, drawheight)
end


return draw
