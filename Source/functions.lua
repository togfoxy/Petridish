functions = {}

function functions.addEntity(dna, x, y)
    -- adds one ENTITIES to the AGENTS arrary
    -- x, y is in screen coordinates

    if dna == nil then dna = {} end

    local entity = concord.entity(ECSWORLD)
    :give("drawable")
    :give("position")
    :give("uid")
    :give("age")

    if dna.grows ~= nil then
        if dna.grows == true then
            entity:give("grows", entity.position.maxRadius, dna.growthRate)    -- NOTE: must be called AFTER "position"
        else
            entity.position.radius = love.math.random(1, 3)
            entity.position.maxRadius = entity.position.radius
        end
    else
        entity.position.radius = love.math.random(1, 3)
        entity.position.maxRadius = entity.position.radius
    end

    local entityType
    if dna.entityType ~= nil then
        entityType = dna.entityType
    else
        entityType = love.math.random(1,5)
    end
    if entityType == 1 then
        -- flora
        entity:give("flora")
        entity.position.sex = 3
    elseif entityType == 2 then
        -- herbivore
        entity:give("herbivore")
        entity.position.sex = love.math.random(1,2)
    elseif entityType == 3 then
        -- carnivore
        entity:give("carnivore")
        entity.position.sex = love.math.random(1,2)
    elseif entityType == 4 then
        -- flora and carnivore
        entity:give("flora")
        entity:give("carnivore")
        entity.position.sex = 3
    elseif entityType == 5 then
        -- herb and carn
        entity:give("herbivore")
        entity:give("carnivore")
        entity.position.sex = love.math.random(1,2)
    else
        error()
    end

    -- post condition
    if entity:has("flora") and entity:has("herbivore") then
        error()
    end

    assert(entity.position.sex > 0)

    if dna.motion ~= nil then
        if dna.motion == true then
            entity:give("motion")
        else
        end
    else
        if not entity:has("flora") then
            if love.math.random(1,3) <= 2 then
                entity:give("motion")
            end
        else
            -- no motion
        end
    end

    if dna.hear ~= nil then
        if dna.hear == true then
            entity:give("hear")
        else
        end
    else
        if not entity:has("flora") then
            if love.math.random(1,2) <= 1 then
                entity:give("hear")
            end
        else
            -- no hearing for plants
        end
    end





    table.insert(ECS_ENTITIES, entity)

    local box2DWidth = DISH_WIDTH / BOX2D_SCALE
	local box2dHeight = SCREEN_HEIGHT / BOX2D_SCALE

    if x == nil then
        x = love.math.random(10, DISH_WIDTH - 10)
        y = love.math.random(10, SCREEN_HEIGHT - 10)
    else
        -- x/y already provided
    end

    -- convert x/y to Box2D scale
    x = x / BOX2D_SCALE
    y = y / BOX2D_SCALE

    local physicsEntity = {}
    physicsEntity.body = love.physics.newBody(PHYSICSWORLD, x, y,"dynamic")
	physicsEntity.body:setLinearDamping(0.4)
	physicsEntity.body:setMass(RADIUSMASSRATIO * (entity.position.radius / BOX2D_SCALE))
	physicsEntity.shape = love.physics.newCircleShape(entity.position.radius / BOX2D_SCALE)
	physicsEntity.fixture = love.physics.newFixture(physicsEntity.body, physicsEntity.shape, 1)		-- the 1 is the density
	physicsEntity.fixture:setRestitution(1.5)
	physicsEntity.fixture:setSensor(false)
	physicsEntity.fixture:setUserData(entity.uid.value)

    table.insert(PHYSICS_ENTITIES, physicsEntity)
end

function functions.getBody(uid)
    assert(uid ~= nil)
    for i = 1, #PHYSICS_ENTITIES do
        if PHYSICS_ENTITIES[i].fixture:getUserData() == uid then
            return PHYSICS_ENTITIES[i]
        end
    end
    return nil
end

function functions.getBodyXY(uid)
    assert(uid ~= nil)
    local physEntity = fun.getBody(uid)
    if physEntity ~= nil then
        return physEntity.body:getX(), physEntity.body:getY()
    else
        return nil
    end
end

function functions.getEntity(uid)
    assert(uid ~= nil)
    for k,v in pairs(ECS_ENTITIES) do
        if v.uid.value == uid then
            return v
        end
    end
    return nil
end

function functions.AmunchB(a, b)
    -- a and b are ECS entities

    if not b:has("attacked") then
    	b.position.radius = b.position.radius - 1
        fun.updatePhysicsRadius(b)
        b:give("attacked")
        b.attacked.attacktimer = 1

        -- energy goes up
        a.position.energy = a.position.energy + 1000
    end
end

function functions.munchBoth(entity1, entity2)
    --!
    local radius1 = entity1.position.radius
    local radius2 = entity2.position.radius
    local totalradius = radius1 + radius2
    local rndnum = love.math.random(1, totalradius)
    if rndnum <= radius1 then
        -- entity1 is wounded
        if not entity1:has("attacked") then
            entity1.position.radius = entity1.position.radius - 1
            fun.updatePhysicsRadius(entity1)
            entity1:give("attacked")
            entity1.attacked.attacktimer = 1

            -- energy goes up
            entity1.position.energy = entity1.position.energy + 1000
        end
    else
        -- entity2 is wounded
        if not entity2:has("attacked") then
            entity2.position.radius = entity2.position.radius - 1
            fun.updatePhysicsRadius(entity2)
            entity2:give("attacked")
            entity2.attacked.attacktimer = 1

            -- energy goes up
            entity2.position.energy = entity2.position.energy + 1000
        end
    end
end

function functions.updatePhysicsRadius(entity)
    -- update the mass on the physics object
    -- entity is an ECS entity
    local uid = entity.uid.value
    local physEntity = fun.getBody(uid)
    local myfixtures = physEntity.body:getFixtures()
    local myshape = myfixtures[1]:getShape()
    myshape:setRadius(entity.position.radius / BOX2D_SCALE)

    -- update the physics mass to whatever the radius is now
    -- NOTE: Box2D doesn't like this here
    -- local newmass = (RADIUSMASSRATIO * entity.position.radius)
    -- physEntity.body:setMass(newmass)

end

function functions.bonk(entity1, entity2)
    --! get location
    -- use random for now
    assert(entity1 ~= nil)
    assert(entity2 ~= nil)

    local dna = {}
    local direction = love.math.random(0, 359)

    local radius1 = entity1.position.radius
    local radius2 = entity2.position.radius
    local radius = math.max(radius1, radius1)
    local x1, y1 = fun.getBodyXY(entity1.uid.value)         -- box2d scale
    if x1 ~= nil then

        x1 = x1 * BOX2D_SCALE
        y1 = y1 * BOX2D_SCALE

        local distance = radius + love.math.random(5, 15)
        local newx, newy = cf.AddVectorToPoint(x1, y1, direction, distance)     -- scren coords

        dna.positionx = newx
        dna.positiony = newy

        -- grows or not
        if entity1:has("grows") and entity2:has("grows") then
            dna.grows = true
            dna.growthRate = (entity1.grows.growthRate + entity2.grows.growthRate) / 2
        elseif not entity1:has("grows") and not entity2:has("grows") then
            dna.grows = false
        else
            if love.math.random(1,2) == 1 then
                dna.grows = true
            else
                dna.grows = false
            end
        end
        -- small chance of mutating
        if love.math.random(1,100) == 1 then
            if love.math.random(1,2) == 1 then
                dna.grows = true
            else
                dna.grows = false
            end
        end

        -- entity type
        if entity1:has("flora") and not entity1:has("carnivore") then dna.entityType = 1 end
        if entity1:has("herbivore") and not entity1:has("carnivore") then dna.entityType = 2 end
        if entity1:has("carnivore") and not entity1:has("herbivore") and not entity1:has("flora") then dna.entityType = 3 end
        if entity1:has("flora") and entity1:has("carnivore") then dna.entityType = 4 end
        if entity1:has("herbivore") and entity1:has("carnivore") then dna.entityType = 5 end

        -- motion
        if entity1:has("motion") and entity2:has("motion") then
            dna.motion = true
        elseif not entity1:has("motion") and not entity2:has("motion") then
            dna.motion = false
        else
            if love.math.random(1,2) == 1 then
                dna.motion = true
            else
                dna.motion = false
            end
        end
        -- small chance of mutating
        if love.math.random(1,100) == 1 then
            if love.math.random(1,2) == 1 then
                dna.motion = true
            else
                dna.motion = false
            end
        end

        fun.addEntity(dna, newx, newy)
        entity1.position.sexRestTimer = SEX_REST_TIMER
        entity2.position.sexRestTimer = SEX_REST_TIMER
    end

end

function functions.createSpawn()
    if #PREGNANT_QUEUE > 0 and #ECS_ENTITIES < MAX_NUMBER_OF_ENTITIES then
        fun.bonk(PREGNANT_QUEUE[1][1],PREGNANT_QUEUE[1][2])
        table.remove(PREGNANT_QUEUE, 1)
    end

end

return functions
