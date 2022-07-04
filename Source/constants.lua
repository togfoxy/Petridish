constants = {}

function constants.load()
    -- constants and globals

    INITAL_NUMBER_OF_ENTITIES = 30
    ECS_ENTITIES = {}
    PHYSICS_ENTITIES = {}

    RADIUSMASSRATIO = 5

    MIN_FLORA_SPAWN_TIMER = 60
    MAX_FLORA_SPAWN_TIMER = 300

    MAX_AGE_MIN = 100
    MAX_AGE_MAX = 1000

    SIDEBAR_WIDTH = 250
    DISH_WIDTH = SCREEN_WIDTH - SIDEBAR_WIDTH
    ZOOMFACTOR = 0.9

    TRANSLATEX = 0
    TRANSLATEY = 0



end


return constants
