local Core = {}

EXITED = -1
PAUSED = 0
LOADING = 1
-- Below are all fine during game
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

Core.update = function(dt)

end

Core.keypressed = function(key, scancode, isrepeat)
    if Core.status == INMENU then
        if key == "return" then
            Core.status = INGAME
        end
    end
end


return Core