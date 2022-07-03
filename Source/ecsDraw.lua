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

            local drawx = entity.position.x
            local drawy = entity.position.y
            local radius = cf.round(entity.position.radius)

            local red, green, blue = 0,0,0

            if entity:has("carnivore") then red = red + 1 end
            if entity:has("flora") then green = green + 1 end
            if entity:has("herbivore") then blue = blue + 1 end

            love.graphics.setColor(red, green, blue, 1)
            love.graphics.circle("fill", drawx, drawy, radius)

            -- facing
            local x2, y2 = cf.AddVectorToPoint(drawx, drawy, entity.position.facing, radius)

            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.line(drawx, drawy, x2, y2)




            -- debug mass
            -- physEntity = fun.getBody(entity.uid.value)
            -- local mass = cf.round(physEntity.body:getMass())
            -- love.graphics.print(mass, drawx + 7, drawy)
        end
    end

    ECSWORLD:addSystems(systemDraw)
end


return ecsDraw
