ecsUpdate = {}

local function calcRadius(entity)
    -- NOTE: assumes entity has a growth rate and age and maximum radius
    local result = entity.grows.growthRate * entity.age.value
    if result > entity.grows.maxRadius then result = entity.grows.maxRadius end
    if result < 3 then result = 3 end
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

    systemPosition = concord.system({
        pool = {"position"}
    })
    function systemPosition:update(dt)
        for _, entity in ipairs(self.pool) do
            -- update the radius if there is age and grows
            if entity:has("grows") and entity:has("age") then
                entity.position.radius = calcRadius(entity)
                -- update the mass on the physics object
                local uid = entity.uid.value
                physEntity = fun.getBody(uid)
                physEntity.body:setMass(RADIUSMASSRATIO * entity.position.radius)
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
            if entity.motion.timer <= 0 then
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
                --
                entity.motion.timer = entity.motion.timer - dt
                if entity.motion.timer < 0 then entity.motion.timer = 0 end
            end

            if entity.motion.currentState == enum.motionMoving then
                -- move towards facing
                local facing = entity.motion.facing       -- 0 -> 359
                local vectordistance = 50
                local x1 = entity.position.x
                local y1 = entity.position.y
                local x2, y2 = cf.AddVectorToPoint(x1, y1, facing, vectordistance)
                local xvector = x2 - x1
                local yvector = y2 - y1

                -- need to scale to 'walking' pace
                -- xvector, yvector = fun.NormaliseVectors(xvector, yvector)
                local physEntity = fun.getBody(entity.uid.value)
                physEntity.body:setLinearVelocity(xvector, yvector)     --! do aceleration at some point

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
