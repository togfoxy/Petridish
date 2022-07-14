GAME_VERSION = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

concord = require 'lib.concord'
-- https://github.com/Tjakka5/Concord

Camera = require 'lib.cam11.cam11'
-- https://notabug.org/pgimeno/cam11

cf = require 'lib.commonfunctions'
constants = require 'constants'
fun = require 'functions'
cmp = require 'components'
ecs = require 'ecsFunctions'
ecsDraw = require 'ecsDraw'
ecsUpdate = require 'ecsUpdate'
draw = require 'draw'
enum = require 'enum'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}

local function bonk(entity1, entity2)
	if entity1.position.sexRestTimer <= 0 and entity2.position.sexRestTimer <= 0 then
		-- bonk

		-- print("spawning via bonking")

		local newspawn = {entity1, entity2}
		table.insert(PREGNANT_QUEUE, newspawn)
		entity1.position.energy = entity1.position.energy - 250
		entity2.position.energy = entity2.position.energy - 250
	end
end

local function initialisePhysics()
	love.physics.setMeter(1)
	PHYSICSWORLD = love.physics.newWorld(0,0,false)
	PHYSICSWORLD:setCallbacks(beginContact,endContact,_,_)

	-- bottom border
	local box2DWidth = DISH_WIDTH / BOX2D_SCALE
	local box2dHeight = SCREEN_HEIGHT / BOX2D_SCALE
	PHYSICSBORDER1 = {}
    PHYSICSBORDER1.body = love.physics.newBody(PHYSICSWORLD, box2DWidth / 2, box2dHeight, "static") --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    PHYSICSBORDER1.shape = love.physics.newRectangleShape(box2DWidth, 5) --make a rectangle with a width of 650 and a height of 50
    PHYSICSBORDER1.fixture = love.physics.newFixture(PHYSICSBORDER1.body, PHYSICSBORDER1.shape) --attach shape to body
	PHYSICSBORDER1.fixture:setUserData("BORDERBOTTOM")
	-- top border
	PHYSICSBORDER2 = {}
    PHYSICSBORDER2.body = love.physics.newBody(PHYSICSWORLD, box2DWidth / 2, 0, "static") --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    PHYSICSBORDER2.shape = love.physics.newRectangleShape(box2DWidth, 5) --make a rectangle with a width of 650 and a height of 50
    PHYSICSBORDER2.fixture = love.physics.newFixture(PHYSICSBORDER2.body, PHYSICSBORDER2.shape) --attach shape to body
	PHYSICSBORDER2.fixture:setUserData("BORDERTOP")
	-- left border
	PHYSICSBORDER3 = {}
    PHYSICSBORDER3.body = love.physics.newBody(PHYSICSWORLD, 0, box2dHeight / 2, "static") --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    PHYSICSBORDER3.shape = love.physics.newRectangleShape(5, box2dHeight) --make a rectangle with a width of 650 and a height of 50
    PHYSICSBORDER3.fixture = love.physics.newFixture(PHYSICSBORDER3.body, PHYSICSBORDER3.shape) --attach shape to body
	PHYSICSBORDER3.fixture:setUserData("BORDERLEFT")
	-- right border
	PHYSICSBORDER4 = {}
    PHYSICSBORDER4.body = love.physics.newBody(PHYSICSWORLD, box2DWidth, box2dHeight / 2, "static") --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    PHYSICSBORDER4.shape = love.physics.newRectangleShape(5, box2dHeight) --make a rectangle with a width of 650 and a height of 50
    PHYSICSBORDER4.fixture = love.physics.newFixture(PHYSICSBORDER4.body, PHYSICSBORDER4.shape) --attach shape to body
	PHYSICSBORDER4.fixture:setUserData("BORDERRIGHT")
end

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
	if key == "kp5" then
		ZOOMFACTOR = 0.9
		TRANSLATEX = cf.round(SCREEN_WIDTH / 2)		-- starts the camera in the middle of the ocean
		TRANSLATEY = cf.round(SCREEN_HEIGHT / 2)	-- need to round because this is working with pixels
	end
end

function love.keypressed( key, scancode, isrepeat )

	local translatefactor = 5 * (ZOOMFACTOR * 2)		-- screen moves faster when zoomed in

	local leftpressed = love.keyboard.isDown("left")
	local rightpressed = love.keyboard.isDown("right")
	local uppressed = love.keyboard.isDown("up")
	local downpressed = love.keyboard.isDown("down")
	local shiftpressed = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")	-- either shift key will work

	-- adjust translatex/y based on keypress combinations
	if shiftpressed then translatefactor = translatefactor * 2 end	-- ensure this line is above the lines below
	if leftpressed then TRANSLATEX = TRANSLATEX - translatefactor end
	if rightpressed then TRANSLATEX = TRANSLATEX + translatefactor end
	if uppressed then TRANSLATEY = TRANSLATEY - translatefactor end
	if downpressed then TRANSLATEY = TRANSLATEY + translatefactor end
end

function love.wheelmoved(x, y)
	if y > 0 then
		-- wheel moved up. Zoom in
		ZOOMFACTOR = ZOOMFACTOR + 0.1
	end
	if y < 0 then
		ZOOMFACTOR = ZOOMFACTOR - 0.1
	end
	if ZOOMFACTOR < 0.5 then ZOOMFACTOR = 0.5 end
	if ZOOMFACTOR > 4 then ZOOMFACTOR = 4 end
end

function love.mousepressed( x, y, button, istouch, presses )

	local wx,wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y

	if button == 1 then
		-- convert mouse point to the physics coordinates
		local x1 = wx
		local y1 = wy

		VESSELS_SELECTED = 0
		for k, entity in pairs(ECS_ENTITIES) do

			local physEntity = fun.getBody(entity.uid.value)
			local x2 = physEntity.body:getX()
			local y2 = physEntity.body:getY()

			x2 = x2 * BOX2D_SCALE
			y2 = y2 * BOX2D_SCALE

			local dist = cf.GetDistance(x1, y1, x2, y2)
			if dist <= 15 then
					entity:ensure("isSelected")
					VESSELS_SELECTED = VESSELS_SELECTED + 1
					SELECTED_VESSEL = entity
			else
				entity:remove("isSelected")
			end

		end
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	if love.mouse.isDown(3) then
		TRANSLATEX = TRANSLATEX - dx
		TRANSLATEY = TRANSLATEY - dy
	end
end

function beginContact(a, b, coll)
	-- a is the first fixture
	-- b is the second fixture
	-- coll is a contact objects

	local entity1, entity2
	local uid1 = a:getUserData()
	local uid2 = b:getUserData()
	assert(uid1 ~= nil)
	assert(uid2 ~= nil)

	if string.sub(uid1, 1, 6) == "BORDER" or string.sub(uid2, 1, 6) == "BORDER" then
		-- collision is with border. Do nothing.
	else
		entity1 = fun.getEntity(uid1)
		entity2 = fun.getEntity(uid2)
		assert(entity1 ~= nil)
		assert(entity2 ~= nil)


		local contactoutcome = fun.getContactOutcome(entity1, entity2)

		if contactoutcome == 0 then
			-- nothing to do
		elseif contactoutcome == 1 then
			-- a munches b
			fun.AmunchB(entity1, entity2)
		elseif contactoutcome == 2 then
			-- b munches a
			fun.AmunchB(entity2, entity1)
		elseif contactoutcome == 3 then
			-- munch each other
			fun.munchBoth(entity1, entity2)
		elseif contactoutcome == 4 then
			-- bonk?
			if entity1.position.sex ~= entity2.position.sex then
				bonk(entity1, entity2)
			end
		elseif contactoutcome == 5 then
			-- bonk or munch
			if entity1.position.sex ~= entity2.position.sex then
				-- bonk
				bonk(entity1, entity2)
			else
				-- munch
				fun.munchBoth(entity1, entity2)
			end
		else
			print(row, col, contactoutcome)
			print(inspect(entity1))
			print("**********")
			print(inspect(entity2))
			error("Unexpected if statement.")
		end
	end
end

function endContact(a, b, coll)
	-- stop movement
end

function love.load()

	constants.load()

	love.window.setMode(800,600,{fullscreen=true, display=1, resizable=true, borderless=false})
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	love.window.setMode(SCREEN_WIDTH,SCREEN_HEIGHT,{fullscreen=false, display=1, resizable=true, borderless=false})

	res.setGame(SCREEN_WIDTH, SCREEN_HEIGHT)

	love.window.setTitle("Petridish " .. GAME_VERSION)
	love.keyboard.setKeyRepeat(true)
	TRANSLATEX = cf.round(SCREEN_WIDTH / 2)		-- starts the camera in the middle of the ocean
    TRANSLATEY = cf.round(SCREEN_HEIGHT / 2)	-- need to round because this is working with pixels

	cam = Camera.new(DISH_WIDTH / 2, SCREEN_HEIGHT / 2, 1)

	-- create the world
    ECSWORLD = concord.world()
	ecsFunctions.init()

	initialisePhysics()

	-- inject initial agents into the dish
	for i = 1, INITAL_NUMBER_OF_ENTITIES do
		fun.addEntity()
	end
end

function love.draw()
    res.start()
	cam:attach()

	ECSWORLD:emit("draw")

	-- debugging
	--cf.printAllPhysicsObjects(PHYSICSWORLD, BOX2D_SCALE)

	cam:detach()
	draw.HUD()

    res.stop()
end

function love.update(dt)

	ECSWORLD:emit("update", dt)

	PHYSICSWORLD:update(dt) --this puts the world into motion

	fun.createSpawn()						-- creates spawn from pregnancy table
	fun.updateGraphs(dt)

	cam:setPos(TRANSLATEX,	TRANSLATEY)
	cam:setZoom(ZOOMFACTOR)

	res.update()

	-- Debugging: show all globals
	-- for globalKey, globalVariableValue in pairs (_G) do
  	-- 	print ( globalKey, globalVariableValue )
	-- end
	-- exit()
end
