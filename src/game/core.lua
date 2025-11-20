local Core = {}

EXITED = -1
PAUSED = 0
LOADING = 1
-- Below are all fine during game
RUNNING = 10
INMENU = 11
INGAME = 12

Core.reset = function()
    -- to be impleneted 
end

Core.load = function()
    Core.status = LOADING
    
    World = love.physics.newWorld(0, 0, true)
    Core.screen = UI.windowResized()

    Core.status = INMENU
end


return Core