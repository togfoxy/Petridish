constants = {}

function constants.load()
    -- constants and globals

    INITAL_NUMBER_OF_ENTITIES = 200
    MAX_NUMBER_OF_ENTITIES = 500
    ECS_ENTITIES = {}

    PREGNANT_QUEUE = {}                 -- queue up parents ready to spawn
    GRAPH = {}

    VESSELS_SELECTED = 0
    SELECTED_VESSEL = nil               -- an actual entity selected by the mouse

    BOX2D_SCALE = 5
    PHYSICS_ENTITIES = {}

    RADIUSMASSRATIO = 5
	MAX_RADIUS = 5						-- maximum radius size permissible

	MIN_MOTION_TIMER = 2				-- minimum time for motion to stop or remain active
	MAX_MOTION_TIMER = 5
    MIN_FLORA_SPAWN_TIMER = 180
    MAX_FLORA_SPAWN_TIMER = 400
	MIN_FACING_TIMER = 2				-- minimum time to maintain facing
	MAX_FACING_TIMER = 7
    SEX_REST_TIMER = 120
    GRAPH_TIMER = 0

    MAX_AGE_MIN = 100
    MAX_AGE_MAX = 1000

    SIDEBAR_WIDTH = 250
    DISH_WIDTH = SCREEN_WIDTH - SIDEBAR_WIDTH
    ZOOMFACTOR = 0.9

    TRANSLATEX = 0
    TRANSLATEY = 0



end


return constants
