GAME_VERSION = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

concord = require 'lib.concord'
-- https://github.com/Tjakka5/Concord

cf = require 'lib.commonfunctions'
constants = require 'constants'
fun = require 'functions'
cmp = require 'components'
ecs = require 'ecsFunctions'
ecsDraw = require 'ecsDraw'
ecsUpdate = require 'ecsUpdate'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
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
	-- love.keyboard.setKeyRepeat(true)

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

	ECSWORLD:emit("draw")


	-- debugging
	-- love.graphics.setColor(1, 0, 0, 1)
	-- for _, body in pairs(PHYSICSWORLD:getBodies()) do
	-- 	for _, fixture in pairs(body:getFixtures()) do
	-- 		local shape = fixture:getShape()
	-- 		local drawx, drawy = body:getWorldPoints(shape:getPoint())
	-- 		love.graphics.circle("line", drawx, drawy, 5)
	-- 	end
	-- end

    res.stop()
end


function love.update(dt)

	ECSWORLD:emit("update", dt)

	PHYSICSWORLD:update(dt) --this puts the world into motion


	res.update()




end
