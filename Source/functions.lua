functions = {}

function functions.addEntity()
    -- adds one ENTITIES to the AGENTS arrary
    -- this is not an ECS thing

    local entity = concord.entity(ECSWORLD)
    -- :give("drawable")
    -- :give("position")
    -- :give("uid")
    -- :give("age")
    table.insert(ECS_ENTITIES, entity)

    -- entity = {}
    -- entity.body = love.physics.newBody(PHYSICSWORLD,x,y,"dynamic")
	-- entity.body:setLinearDamping(0.5)
	-- entity.body:setMass(1)
	-- entity.shape = love.physics.newCircleShape(5)      --!
	-- entity.fixture = love.physics.newFixture(entity.body, entity.shape, 1)		-- the 1 is the density
	-- entity.fixture:setRestitution(1.5)
	-- entity.fixture:setSensor(false)
	-- entity.fixture:setUserData(botindex)
    --
	-- entity.linearvelocityx = 0
	-- entity.linearvelocityy = 0
    -- entity.x = 100
    -- entity.y = 100
    --
    -- table.insert(PHYSICS_ENTITIES, entity)
end



return functions
