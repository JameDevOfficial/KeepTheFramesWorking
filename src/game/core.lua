local Core = {}

RUNNING = 10
INMENU = 11
INGAME = 12
INFINISH = 13
PAUSED = 0

Core.status = INMENU
World = love.physics.newWorld(0, 0, true)

Core.reset = function()
    -- to be impleneted 
end

Core.load = function()

end


return Core