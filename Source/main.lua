GAME_VERSION = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

concord = require 'lib.concord'
-- https://github.com/Tjakka5/Concord

cf = require 'lib.commonfunctions'
constants = require 'constants'

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

	res.setGame(SCREEN_WIDTH, SCREEN_HEIGHT)

    if love.filesystem.isFused( ) then
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    else
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    end

	love.window.setTitle("Petridish " .. GAME_VERSION)

	love.physics.setMeter(1)
	world = love.physics.newWorld(0,0,false)
	world:setCallbacks(beginContact,endContact,_,_)


	-- cf.AddScreen("MainMenu", SCREEN_STACK)

end


function love.draw()

    res.start()





    res.stop()
end


function love.update(dt)

	world:update(dt) --this puts the world into motion


	res.update()




end
