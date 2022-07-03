cmp = {}

function cmp.init()
    -- establish all the components
    concord.component("uid", function(c)
        c.value = cf.Getuuid()
    end)
    concord.component("drawable")   -- will be drawn during love.draw()

    concord.component("isSelected") -- clicked by the mouse

    concord.component("age", function(c, startage, maxage)
        if startage == nil then
            c.value = 0
        else
            c.value = startage
        end
        c.maxAge = maxage or love.math.random(MAX_AGE_MIN, MAX_AGE_MAX)
    end)

    concord.component("grows", function(c)
        -- NOTE: grows assumes entity has AGE
        c.growthRate = 0.25        -- growth rate per dt
        c.maxRadius = 10            --!
    end)

    concord.component("position", function(c, x, y)
        c.x = love.math.random(50, DISH_WIDTH - 50)
        c.y = love.math.random(50, SCREEN_HEIGHT - 50)

        c.previousx = c.x
        c.previousy = c.y
        c.movementDelta = 0     -- track movement for animation purposes
        c.radius = 1            -- the size of the entity
    end)

    concord.component("flora")
    concord.component("herbivore")
    concord.component("carnivore")

    concord.component("motion", function(c, speed)
        c.currentSpeed = 0
        c.maxSpeed = love.math.random(1, 10)    --! tweak
        c.aceleration = love.math.random(1, 10) / 10
        c.facing = love.math.random(0, 359)     -- random compass facing
        c.desiredfacing = c.facing
        c.turnrate = love.math.random(5, 30)        -- degrees
        c.currentState = enum.motionMoving
    end)
end

return cmp
