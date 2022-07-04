functions = {}

function functions.addEntity()
    -- adds one ENTITIES to the AGENTS arrary
    -- this is not an ECS thing

    local entity = concord.entity(ECSWORLD)
    :give("drawable")
    :give("position")
    :give("uid")
    :give("age")

    if love.math.random(1,2) == 1 then
        entity:give("grows", entity.position.maxRadius)    -- NOTE: must be called AFTER "position"
    else
        entity.position.radius = love.math.random(1, 3)
    end

    local entityType = love.math.random(1,5)
    if entityType == 1 then
        -- flora
        entity:give("flora")
    elseif entityType == 2 then
        -- herbivore
        entity:give("herbivore")
    elseif entityType == 3 then
        -- carnivore
        entity:give("carnivore")
    elseif entityType == 4 then
        -- flora and carnivore
        entity:give("flora")
        entity:give("carnivore")
    elseif entityType == 5 then
        -- herb and carn
        entity:give("herbivore")
        entity:give("carnivore")
    else
        error()
    end

    if love.math.random(1,2) == 1 and not entity:has("flora") then  -- plants can't move
        entity:give("motion")
    else
        -- no motion
    end

    -- post condition
    if entity:has("flora") and entity:has("herbivore") then
        error()
    end

    table.insert(ECS_ENTITIES, entity)

    local rndx = love.math.random(50, DISH_WIDTH - 50)
    local rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    local physicsEntity = {}
    physicsEntity.body = love.physics.newBody(PHYSICSWORLD, rndx, rndy,"dynamic")
	physicsEntity.body:setLinearDamping(0.5)
	physicsEntity.body:setMass(RADIUSMASSRATIO * entity.position.radius)
	physicsEntity.shape = love.physics.newCircleShape(entity.position.radius)
	physicsEntity.fixture = love.physics.newFixture(physicsEntity.body, physicsEntity.shape, 1)		-- the 1 is the density
	physicsEntity.fixture:setRestitution(1.5)
	physicsEntity.fixture:setSensor(false)
	physicsEntity.fixture:setUserData(entity.uid.value)

	physicsEntity.linearvelocityx = 0
	physicsEntity.linearvelocityy = 0
    physicsEntity.x = entity.position.x
    physicsEntity.y = entity.position.y

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
    assert(physEntity ~= nil)
    return physEntity.body:getX(), physEntity.body:getY()
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
    -- a and b are entities

	b.position.radius = b.position.radius - 1
    fun.updatePhysicsRadius(b)
    print("Ack! Radius is now " .. b.position.radius)

	-- a energy goes up
	--!
end

function functions.munchBoth(entity1, entity2)
    --!
    local radius1 = entity1.position.radius
    local radius2 = entity2.position.radius
    local totalradius = radius1 + radius2
    local rndnum = love.math.random(1, totalradius)
    if rndnum <= radius1 then
        -- entity1 is wounded
        entity1.position.radius = entity1.position.radius - 1
        fun.updatePhysicsRadius(entity1)
        entity1:give("attacked")
        print("Oof! Radius is now " .. entity1.position.radius)
    else
        -- entity2 is wounded
        entity2.position.radius = entity2.position.radius - 1
        fun.updatePhysicsRadius(entity2)
        entity2:give("attacked")
        print("Bam! Radius is now " .. entity2.position.radius)
    end
end

function functions.updatePhysicsRadius(entity)
    -- update the mass on the physics object
    local uid = entity.uid.value
    local physEntity = fun.getBody(uid)
    --! physEntity.body:setMass(RADIUSMASSRATIO * entity.position.radius)
    local myfixtures = physEntity.body:getFixtures()
    local myshape = myfixtures[1]:getShape()
    myshape:setRadius(entity.position.radius)
end
return functions
