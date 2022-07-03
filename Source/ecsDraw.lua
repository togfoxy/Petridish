ecsDraw = {}

function ecsDraw.draw()

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

            love.graphics.circle("fill", drawx, drawy, 5)
        end
    end

    ECSWORLD:addSystems(systemDraw)
end


return ecsDraw
