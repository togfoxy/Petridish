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

            love.graphics.circle("fill", drawx, drawy, radius)

            physEntity = fun.getBody(entity.uid.value)
            local mass = cf.round(physEntity.body:getMass())
            love.graphics.print(mass, drawx + 7, drawy)
        end
    end

    ECSWORLD:addSystems(systemDraw)
end


return ecsDraw
