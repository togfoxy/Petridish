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

	-- bottom border
	PHYSICSBORDER1 = {}
    PHYSICSBORDER1.body = love.physics.newBody(PHYSICSWORLD, DISH_WIDTH / 2, SCREEN_HEIGHT - 10, "static") --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    PHYSICSBORDER1.shape = love.physics.newRectangleShape(DISH_WIDTH, 5) --make a rectangle with a width of 650 and a height of 50
    PHYSICSBORDER1.fixture = love.physics.newFixture(PHYSICSBORDER1.body, PHYSICSBORDER1.shape) --attach shape to body
	-- top border
	PHYSICSBORDER2 = {}
    PHYSICSBORDER2.body = love.physics.newBody(PHYSICSWORLD, DISH_WIDTH / 2, 10, "static") --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    PHYSICSBORDER2.shape = love.physics.newRectangleShape(DISH_WIDTH, 5) --make a rectangle with a width of 650 and a height of 50
    PHYSICSBORDER2.fixture = love.physics.newFixture(PHYSICSBORDER2.body, PHYSICSBORDER2.shape) --attach shape to body
	-- left border
	PHYSICSBORDER3 = {}
    PHYSICSBORDER3.body = love.physics.newBody(PHYSICSWORLD, 10, SCREEN_HEIGHT / 2, "static") --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    PHYSICSBORDER3.shape = love.physics.newRectangleShape(5, SCREEN_HEIGHT) --make a rectangle with a width of 650 and a height of 50
    PHYSICSBORDER3.fixture = love.physics.newFixture(PHYSICSBORDER3.body, PHYSICSBORDER3.shape) --attach shape to body
	-- right border
	PHYSICSBORDER4 = {}
    PHYSICSBORDER4.body = love.physics.newBody(PHYSICSWORLD, DISH_WIDTH - 10, SCREEN_HEIGHT / 2, "static") --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    PHYSICSBORDER4.shape = love.physics.newRectangleShape(5, SCREEN_HEIGHT) --make a rectangle with a width of 650 and a height of 50
    PHYSICSBORDER4.fixture = love.physics.newFixture(PHYSICSBORDER4.body, PHYSICSBORDER4.shape) --attach shape to body



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
	-- love.graphics.setColor(1, 0, 0, 1)
	-- for _, body in pairs(PHYSICSWORLD:getBodies()) do
	-- 	for _, fixture in pairs(body:getFixtures()) do
	-- 		local shape = fixture:getShape()
	--
	-- 		if shape:typeOf("CircleShape") then
	-- 			local drawx, drawy = body:getWorldPoints(shape:getPoint())
	-- 			local radius = shape:getRadius()
	-- 			love.graphics.circle("line", drawx, drawy, radius)
	-- 			love.graphics.print(cf.round(radius,2), drawx + 7, drawy - 3)
	-- 		elseif shape:typeOf("PolygonShape") then
    --         	love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
	-- 		else
	-- 			love.graphics.line(body:getWorldPoints(shape:getPoints()))
	-- 		end
	-- 	end
	-- end

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
