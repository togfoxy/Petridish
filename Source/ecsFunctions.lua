ecsFunctions = {}

function ecsFunctions.init()

    cmp.init()

    ecsDraw.draw()

    systemAge = concord.system({
        pool = {"age"}
    })

    function systemAge:update(dt)
        for _, entity in ipairs(self.pool) do
        end
    end
    ECSWORLD:addSystems(systemAge)

end


return ecsFunctions
