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

    Core.world = love.physics.newWorld(0, 0, true)
    Core.screen = UI.windowResized()
    Core.player = Player:new({ color = { 1, 0.4, 1 }, world = Core.world })
    Core.centerFrame = CF:new({ world = Core.world })

    Core.status = INMENU
end

Core.update = function(dt)
    Core.world:update(dt)
    Core.centerFrame:update(dt)
    Core.player:update(dt)

    if Core.status == INGAME then
        Player.points = Player.points + dt
    end
end

Core.keypressed = function(key, scancode, isrepeat)
    if key == "f5" then
        Settings.DEBUG = not Settings.DEBUG
    end

    if Core.status == INMENU then
        if key == "return" then
            Core.status = INGAME
        end
    end
    if Core.status == INGAME then
        local dt = love.timer.getDelta()

        if key == "space" then
            Core.player:shoot(love.timer.getDelta())
        end
    end
end


return Core
