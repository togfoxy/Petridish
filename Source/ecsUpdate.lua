ecsUpdate = {}

local function calcRadius(entity)
    -- NOTE: assumes entity has a growth rate and age and maximum radius
    local result = entity.grows.growthRate * entity.age.value		-- the age.value already has dt
    if result > entity.grows.maxRadius then result = entity.grows.maxRadius end
    assert(result > 0)
    return result
end

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

	systemAttacked = concord.system({
		pool = {"attacked"}
	})
	function systemAttacked:update(dt)
		for _, entity in ipairs(self.pool) do
			entity.attacked.attackedtime = entity.attacked.attackedtime - dt
			if entity.attacked.attackedtime <= 0 then
				entity:remove("attacked")
			end

			if entity.position.radius <= 0 then
				killEntity(entity)
			end
		end
	end
	ECSWORLD:addSystems(systemAttacked)

    systemPosition = concord.system({
        pool = {"position"}
    })
    function systemPosition:update(dt)
        for _, entity in ipairs(self.pool) do
            -- update the radius every loop

            if entity:has("grows") and entity:has("age") then
				entity.position.radius = calcRadius(entity)		-- assumes "grows" and "age"
                -- update the mass on the physics object
                local uid = entity.uid.value
                local physEntity = fun.getBody(uid)
                physEntity.body:setMass(RADIUSMASSRATIO * entity.position.radius)
                local myfixtures = physEntity.body:getFixtures()
                local myshape = myfixtures[1]:getShape()
                myshape:setRadius(entity.position.radius)
            end

			if not entity:has("attacked") and entity:has("position") then
                --!
                -- if entity.position.radius < entity.position.maxRadius then
	            --     -- heal
                --     entity.position.radius = entity.position.radius + entity.position.radiusHealRate * dt		--! fix healrate
                -- end
			end
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

            if entity.motion.currentState == enum.motionMoving then
                -- move towards facing
                local facing = entity.motion.facing       -- 0 -> 359
                local vectordistance = 5000 * dt
                local x1,y1 = fun.getBodyXY(entity.uid.value)
                local x2, y2 = cf.AddVectorToPoint(x1, y1, facing, vectordistance)
                local xvector = x2 - x1
                local yvector = y2 - y1

                -- need to scale to 'walking' pace
                -- xvector, yvector = fun.NormaliseVectors(xvector, yvector)
                local physEntity = fun.getBody(entity.uid.value)
                physEntity.body:setLinearVelocity(xvector, yvector)     --! do aceleration at some point
																		--! does this factor mass?

                -- update the entity x/y based on the physical body
                local physEntityX = physEntity.body:getX()
                local physEntityY = physEntity.body:getY()

                entity.position.x = physEntityX
                entity.position.y = physEntityY
            else
                local physEntity = fun.getBody(entity.uid.value)
                physEntity.body:setLinearVelocity(0, 0)     --! do aceleration at some point
            end
        end
    end
    ECSWORLD:addSystems(systemMotion)

end
return ecsUpdate
