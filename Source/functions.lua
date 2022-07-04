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
        entity:give("grows")
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

	-- b radius = b radius -1
	b.position.radius = entity.position.radius - 1

	-- a energy goes up
	--!



end

return functions
