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

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
	if key == "kp5" then
		ZOOMFACTOR = 1
		TRANSLATEX = 960
		TRANSLATEY = 540
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
	if ZOOMFACTOR < 0.8 then ZOOMFACTOR = 0.8 end
	if ZOOMFACTOR > 4 then ZOOMFACTOR = 4 end
end

function beginContact(a, b, coll)
	-- a is the first fixture
	-- b is the second fixture
	-- coll is a contact objects

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

	cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)

	-- create the world
    ECSWORLD = concord.world()
	ecsFunctions.init()

	love.physics.setMeter(1)
	PHYSICSWORLD = love.physics.newWorld(0,0,false)
	PHYSICSWORLD:setCallbacks(beginContact,endContact,_,_)

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
	love.graphics.setColor(1, 0, 0, 1)
	for _, body in pairs(PHYSICSWORLD:getBodies()) do
		for _, fixture in pairs(body:getFixtures()) do
			local shape = fixture:getShape()
			local drawx, drawy = body:getWorldPoints(shape:getPoint())
			love.graphics.circle("line", drawx, drawy, 5)
		end
	end

	cam:detach()
	draw.HUD()

    res.stop()
end


function love.update(dt)

	ECSWORLD:emit("update", dt)

	PHYSICSWORLD:update(dt) --this puts the world into motion


	cam:setPos(TRANSLATEX,	TRANSLATEY)
	cam:setZoom(ZOOMFACTOR)

	res.update()
end
