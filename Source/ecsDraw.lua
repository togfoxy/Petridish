ecsDraw = {}

function ecsDraw.init()

    -- profiler.start()

    systemDraw = concord.system({
        pool = {"position", "drawable"}
    })
    -- define same systems
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)
        for _, entity in ipairs(self.pool) do

            local uid = entity.uid.value
            local physEntity = fun.getBody(uid)

            local drawx = physEntity.body:getX()
            local drawy = physEntity.body:getY()
            local radius = (entity.position.radius)

            local red, green, blue = 0,0,0

            if entity:has("carnivore") then red = red + 1 end
            if entity:has("flora") then green = green + 1 end
            if entity:has("herbivore") then blue = blue + 1 end

            love.graphics.setColor(red, green, blue, 1)
            love.graphics.circle("fill", drawx, drawy, radius)

            -- facing
            if entity:has("motion") then
                local x2, y2 = cf.AddVectorToPoint(drawx, drawy, entity.motion.facing, radius)

                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.line(drawx, drawy, x2, y2)
            end


            -- debug
            -- love.graphics.print("mr:" .. cf.round(entity.position.maxRadius,2), drawx + 7, drawy +2)
            -- if entity:has("grows") then love.graphics.print("growing", drawx, drawy +15) end
            -- love.graphics.print(cf.round(radius,2), drawx - 17, drawy)
            -- love.graphics.print("m:" .. cf.round(physEntity.body:getMass(),2), drawx -25, drawy -25)
            -- speed
            -- local velx, vely = physEntity.body:getLinearVelocity()
            -- local vel = math.max(velx,vely)
            -- love.graphics.print("v:" .. cf.round(vel, 2), drawx + 25, drawy + 15)
            love.graphics.print("e:" .. cf.round(entity.position.energy, 2), drawx + 25, drawy + 5)

            -- debug mass
            -- physEntity = fun.getBody(entity.uid.value)
            -- local mass = cf.round(physEntity.body:getMass())
            -- love.graphics.print(mass, drawx + 7, drawy)
        end
    end

    ECSWORLD:addSystems(systemDraw)
end


return ecsDraw
