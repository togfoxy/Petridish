ecsUpdate = {}

local function calcRadius(entity)
    -- NOTE: assumes entity has a growth rate and age and maximum radius
    local result = entity.grows.growthRate * entity.age.value
    if result > entity.grows.maxRadius then result = entity.grows.maxRadius end
    if result < 3 then result = 3 end
    return result
end

function ecsUpdate.init()

    systemAge = concord.system({
        pool = {"age"}
    })
    function systemAge:update(dt)
        for _, entity in ipairs(self.pool) do
            entity.age.value = entity.age.value + dt
        end
    end
    ECSWORLD:addSystems(systemAge)

    systemPosition = concord.system({
        pool = {"position"}
    })
    function systemPosition:update(dt)
        for _, entity in ipairs(self.pool) do
            --! update the radius if there is age and grows
            if entity:has("grows") and entity:has("age") then
                entity.position.radius = calcRadius(entity)
            end
        end
    end
    ECSWORLD:addSystems(systemPosition)
end

return ecsUpdate
