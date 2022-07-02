ecsFunctions = {}

function ecsFunctions.init()

    cmp.init()

    systemAge = concord.system({
        pool = {"age"}
    })

    function systemAge:update(dt)
        for _, entity in ipairs(self.pool) do
        end
    end
    WORLD:addSystems(systemAge)

end


return ecsFunctions
