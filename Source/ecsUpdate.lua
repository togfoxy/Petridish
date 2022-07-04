ecsUpdate = {}

local function killEntity(entity)
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
    print("Entity removed.")

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
            local newmass = (RADIUSMASSRATIO * entity.position.radius)
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
                if love.math.random(1,2) == 1 then
                    -- move!
                    entity.motion.currentState = enum.motionMoving
                    entity.motion.timer = love.math.random(2, 5)       -- seconds       --! make globals
                else
                    -- don't move
                    entity.motion.currentState = enum.motionResting
                    entity.motion.timer = love.math.random(2, 5)       -- seconds       --! make globals
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
                local vectordistance = 5000 * dt
                local x1,y1 = fun.getBodyXY(entity.uid.value)
                local x2, y2 = cf.AddVectorToPoint(x1, y1, facing, vectordistance)
                local xvector = (x2 - x1) * 100000 * dt     --! can adjust the force and the energy used
                local yvector = (y2 - y1) * 100000 * dt

                physEntity.body:applyForce(xvector, yvector)
                entity.position.energy = entity.position.energy - (10 * dt)

            else
                -- local physEntity = fun.getBody(entity.uid.value)
                -- physEntity.body:setLinearVelocity(0, 0)     --! do aceleration at some point
                local velx, vely = physEntity.body:getLinearVelocity()
                physEntity.body:setLinearVelocity(velx / 0.9 * dt, vely / 0.9 * dt)
            end
        end
    end
    ECSWORLD:addSystems(systemMotion)

end
return ecsUpdate
