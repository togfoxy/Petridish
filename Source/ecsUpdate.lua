ecsUpdate = {}

local function killEntity(entity, reason)
    -- unit test
    local ecsOrigsize = #ECS_ENTITIES
    local physicsOrigsize = #PHYSICS_ENTITIES
    --

    -- destroy the body then remove empty body from the array
    for i = 1, #PHYSICS_ENTITIES do
        if PHYSICS_ENTITIES[i].fixture:getUserData() == entity.uid.value then     --!
            PHYSICS_ENTITIES[i].body:destroy()
            table.remove(PHYSICS_ENTITIES, i)
            break
        end
    end

    -- remove the entity from the arrary
    for i = 1, #ECS_ENTITIES do
        if ECS_ENTITIES[i] == entity then
            table.remove(ECS_ENTITIES, i)
            break
        end
    end

    -- destroy the entity
    entity:destroy()

    reason = reason or ""
    print("Entity removed due to " .. reason)

    -- unit test
    assert(#ECS_ENTITIES < ecsOrigsize)
    assert(#PHYSICS_ENTITIES < physicsOrigsize)
end

function ecsUpdate.init()

    systemAge = concord.system({
        pool = {"age"}
    })
    function systemAge:update(dt)
        for _, entity in ipairs(self.pool) do
            entity.age.value = entity.age.value + dt
            if entity.age.value > entity.age.maxAge then
                killEntity(entity)
            end
        end
    end
    ECSWORLD:addSystems(systemAge)

    systemGrows = concord.system({
        pool = {"grows"}
    })
    function systemGrows:update(dt)
        for _, entity in ipairs(self.pool) do
            if entity.grows.growthLeft > 0 then
                entity.position.radius = entity.position.radius + (entity.grows.growthRate * dt)
                entity.grows.growthLeft = entity.grows.growthLeft - (entity.grows.growthRate * dt)
                entity.position.energy = entity.position.energy - (entity.grows.growthRate * dt * 250)     -- an arbitrary value

                if entity.grows.growthLeft <= 0 then
                    entity:remove("grows")
                end
                fun.updatePhysicsRadius(entity)
            end
        end
    end
    ECSWORLD:addSystems(systemGrows)

    systemFlora = concord.system({
        pool = {"flora"}
    })
    function systemFlora:update(dt)
        for _, entity in ipairs(self.pool) do
            -- grow and spread
            entity.flora.spreadtimer = entity.flora.spreadtimer - dt
            if entity.flora.spreadtimer <= 0 then
                entity.flora.spreadtimer = love.math.random(MIN_FLORA_SPAWN_TIMER, MAX_FLORA_SPAWN_TIMER)
                -- create a new flora entity
                local dna = fun.getDNA(entity)      -- dna table

                -- determine the new x/y
                local x = dna.x
                local y = dna.y
                local direction = love.math.random(0, 359)
                local radius = entity.position.radius
                local distance = radius + love.math.random(5, 15)
                local newx, newy = cf.AddVectorToPoint(x,y,direction,distance)

                fun.mutateDNA(dna, 1)
                fun.addEntity(dna, newx, newy)
                entity.position.energy = entity.position.energy - 500
            end
        end
    end
    ECSWORLD:addSystems(systemFlora)

	systemAttacked = concord.system({
		pool = {"attacked"}
	})
	function systemAttacked:update(dt)
		for _, entity in ipairs(self.pool) do
			entity.attacked.attacktimer = entity.attacked.attacktimer - dt
			if entity.attacked.attacktimer <= 0 then
				entity:remove("attacked")   -- remove so entity can heal during position update
			end
		end
	end
	ECSWORLD:addSystems(systemAttacked)

    systemPosition = concord.system({
        pool = {"position"}
    })
    function systemPosition:update(dt)
        for _, entity in ipairs(self.pool) do
			if not entity:has("attacked") then
                if entity.position.radius < entity.position.maxRadius then
	                -- heal
                    entity.position.radius = entity.position.radius + entity.position.radiusHealRate * dt
                    entity.position.energy = entity.position.energy - entity.position.radiusHealRate * dt
                    fun.updatePhysicsRadius(entity)
                end
			end

            -- use up energy
            entity.position.energy = entity.position.energy - dt

            -- update the physics mass to whatever the radius is now
            local newmass = (RADIUSMASSRATIO * (entity.position.radius / BOX2D_SCALE))
            local physEntity = fun.getBody(entity.uid.value)
            physEntity.body:setMass(newmass)

            -- NOTE: ensure this happens last to avoid operations on a nil value
            if entity.position.energy <= 0 or entity.position.radius <= 0 then killEntity(entity) end
        end
    end
    ECSWORLD:addSystems(systemPosition)

    systemMotion = concord.system({
        pool = {"motion"}
    })
    function systemMotion:update(dt)
        for _, entity in ipairs(self.pool) do

            -- can move. Need to decide if it should
            if entity.motion.motiontimer <= 0 then
                -- not currently doing anything. Decision time
                if love.math.random(1,5) == 1 then
                    -- move!
                    entity.motion.currentState = enum.motionMoving
                    entity.motion.motiontimer = love.math.random(2, 5)       -- seconds       --! make globals

                else
                    -- don't move
                    entity.motion.currentState = enum.motionResting
                    entity.motion.motiontimer = love.math.random(2, 5)       -- seconds       --! make globals
                end
            else
                entity.motion.motiontimer = entity.motion.motiontimer - dt
                if entity.motion.motiontimer < 0 then entity.motion.motiontimer = 0 end
            end

            -- decide to turn left or right
            if entity.motion.facingtimer < 0 then
                entity.motion.facingtimer = 0
                -- decide to change desired facing
                if love.math.random(1,2) == 1 then
                    entity.motion.desiredfacing = love.math.random(0, 359)
                    entity.motion.facingtimer = love.math.random(2, 7)      --! make constants
                end
            else
                entity.motion.facingtimer = entity.motion.facingtimer - dt
            end

            -- turn if necessary
            local newheading
            local steeringamount = entity.motion.turnrate
            local currentfacing = entity.motion.facing
            local desiredfacing = entity.motion.desiredfacing
            local angledelta = desiredfacing - currentfacing
            local adjustment = math.min(math.abs(angledelta), steeringamount)
            adjustment = adjustment * dt

            -- determine if cheaper to turn left or right
            local leftdistance = currentfacing - desiredfacing
            if leftdistance < 0 then leftdistance = 360 + leftdistance end      -- this is '+' because leftdistance is a negative value

            local rightdistance = desiredfacing - currentfacing
            if rightdistance < 0 then rightdistance = 360 + rightdistance end   -- this is '+' because leftdistance is a negative value

            if leftdistance < rightdistance then
               -- print("turning left " .. adjustment)
               newheading = currentfacing - (adjustment)
            else
               -- print("turning right " .. adjustment)
               newheading = currentfacing + (adjustment)
            end
            if newheading < 0 then newheading = 360 + newheading end
            if newheading > 359 then newheading = newheading - 360 end

            entity.motion.facing = (newheading)

            -- move towards facing
            local physEntity = fun.getBody(entity.uid.value)
            if entity.motion.currentState == enum.motionMoving then
                local facing = entity.motion.facing       -- 0 -> 359
                local vectordistance = 100
                local x1,y1 = fun.getBodyXY(entity.uid.value)
                local x2, y2 = cf.AddVectorToPoint(x1, y1, facing, vectordistance)
                local xvector = (x2 - x1) * 20 * dt     --! can adjust the force and the energy used
                local yvector = (y2 - y1) * 20 * dt

                physEntity.body:applyForce(xvector, yvector)
                entity.position.energy = entity.position.energy - (10 * dt)
                -- make noise
                entity.motion.currentNoiseDistance = entity.motion.currentNoiseDistance + (entity.motion.makesNoise * dt)
                if entity.motion.currentNoiseDistance > entity.motion.maxNoise then entity.motion.currentNoiseDistance = entity.motion.maxNoise end
            else
                -- not moving so slow down
                -- linear damping will slow the item down

                entity.motion.currentNoiseDistance = entity.motion.currentNoiseDistance - dt
                if entity.motion.currentNoiseDistance < 0 then entity.motion.currentNoiseDistance = 0 end
            end
        end
    end
    ECSWORLD:addSystems(systemMotion)

end
return ecsUpdate
