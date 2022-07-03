cmp = {}

function cmp.init()
    -- establish all the components
    concord.component("uid", function(c)
        c.value = cf.Getuuid()
    end)
    concord.component("drawable")   -- will be drawn during love.draw()

    concord.component("isSelected") -- clicked by the mouse

    concord.component("position", function(c, x, y)
        c.x = love.math.random(50, SCREEN_WIDTH - 50)
        c.y = love.math.random(50, SCREEN_HEIGHT - 50)
        c.facing = love.math.random(0, 359)     -- random compass facing
        c.previousx = c.x
        c.previousy = c.y
        c.movementDelta = 0     -- track movement for animation purposes
    end)

    concord.component("age", function(c, startage, maxage)
        if startage == nil then
            c.age = 0
        else
            c.age = startage
        end
        c.maxage = maxage or love.math.random(100, 1000)
    end)
end

return cmp
