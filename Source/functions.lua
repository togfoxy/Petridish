functions = {}

function functions.addEntity()
    -- adds one ENTITIES to the AGENTS arrary
    -- this is not an ECS thing


    local villager = concord.entity(WORLD)
    :give("drawable")
    :give("position")
    :give("uid")
    :give("isPerson")
    table.insert(VILLAGERS, villager)



    local entity = {}

    entity.body = love.physics.newBody(world,x,y,"dynamic")
	entity.body:setLinearDamping(0.5)
	entity.body:setMass(1)
	entity.shape = love.physics.newCircleShape(gintBotRadius)
	entity.fixture = love.physics.newFixture(Bots[botindex].body, Bots[botindex].shape, 1)		-- the 1 is the density
	entity.fixture:setRestitution(1.5)
	entity.fixture:setSensor(false)
	entity.fixture:setUserData(botindex)

	entity.linearvelocityx = 0
	entity.linearvelocityy = 0

    table.insert(ENTITIES, entity)


end



return functions
