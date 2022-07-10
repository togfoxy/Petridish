draw = {}

function draw.HUD()

    local drawx = SCREEN_WIDTH - SIDEBAR_WIDTH
    local drawy = 0
    local drawwidth = SIDEBAR_WIDTH
    local drawheight = SCREEN_HEIGHT

    love.graphics.setColor(174/255, 174/255, 174/255, 0.8)
    love.graphics.rectangle("fill", drawx, drawy, drawwidth, drawheight)

    if VESSELS_SELECTED == 1 then
        --! draw things on sidebar

        local drawx = DISH_WIDTH + 10
        local drawy = 10

        love.graphics.setColor(1,1,1,1)

        love.graphics.print("Enery: " .. cf.round(SELECTED_VESSEL.position.energy, 0), drawx, drawy)
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
end


return draw
