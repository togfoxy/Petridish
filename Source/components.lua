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

    concord.component("position", function(c)
        c.movementDelta = 0     -- track movement for animation purposes
        c.radius = 1            -- this is in ECS units, not BOX2D units
        c.maxRadius = love.math.random(1, MAX_RADIUS)
		c.radiusHealRate = love.math.random(5,15) / 100
        c.energy = 5000       -- seconds if not moving

        c.sex = 0               -- 1 = male; 2 = female; 3 = asexual
        c.sexRestTimer = 0           -- the time before can have more sex
    end)

    concord.component("grows", function(c, maxrad, grate)
        -- NOTE: maxrad is the maximum radius
        assert(maxrad ~= nil)
        -- c.growthRate = 0.25        -- growth rate per dt
        if grate == nil then
            c.growthRate = love.math.random(20, 30) / 100
        else
            c.growthRate = grate
        end
        c.growthLeft = maxrad / c.growthRate       -- number of times this entity can grow (full maturity)
    end)

    concord.component("flora", function(c)
        c.spreadtimer = love.math.random(MIN_FLORA_SPAWN_TIMER, MAX_FLORA_SPAWN_TIMER)    -- will spawn this often
    end)

    concord.component("herbivore")
    concord.component("carnivore")

    concord.component("motion", function(c, speed)
        c.maxSpeed = love.math.random(1, 10)    --! tweak
        c.facing = love.math.random(0, 359)     -- random compass facing
        c.desiredfacing = c.facing
        c.turnrate = love.math.random(5, 30)        -- degrees      --! add to dna
        c.currentState = enum.motionMoving
        c.motiontimer = 0             -- moves for this many seconds
        c.facingtimer = 0             -- won't try to change desired facing for this long
        c.maxNoise = love.math.random(25, 70)   -- maximimum noise it makes (ECS distance)      --! include in DNA
        c.makesNoise = love.math.random(2, 8)   -- how much noise it makes per movement         --! include in DNA
        c.currentNoiseDistance = 0           -- current noise level
    end)

    concord.component("hear")

	concord.component("attacked", function(c)
		c.attacktimer = 0	-- tracks when it can be next attacked
	end)
end

return cmp
