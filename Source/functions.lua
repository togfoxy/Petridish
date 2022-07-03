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

    local entityType = love.math.random(1,3)
    if entityType == 1 then
        -- flora
        entity:give("flora")
    elseif entityType == 2 then
        -- herbivore
        entity:give("herbivore")
    elseif entityType == 3 then
        -- carnivore
        entity:give("carnivore")
    else
        error()
    end

    table.insert(ECS_ENTITIES, entity)

    local physicsEntity = {}
    physicsEntity.body = love.physics.newBody(PHYSICSWORLD,entity.position.x,entity.position.y,"dynamic")
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



return functions
