local Core = {}

EXITED = -1
PAUSED = 0
LOADING = 1
-- Below are all fine during game
INMENU = 11
INGAME = 12

Core.enemies = {}

Core.reset = function()
    -- to be impleneted
end

Core.load = function()
    Core.status = LOADING

    Core.world = love.physics.newWorld(0, 0, true)
    Core.screen = UI.windowResized()
    Core.player = Player:new({ color = Settings.player.color, world = Core.world })
    Core.centerFrame = CF:new({ world = Core.world })

    Core.status = INMENU
end

Core.update = function(dt)
    Core.world:update(dt)
    Core.centerFrame:update(dt)
    Core.player:update(dt)


    if Core.status == INGAME then
        Player.points = Player.points + dt
        local enemy = Enemy:spawnRandom(dt)
        if enemy then table.insert(Core.enemies, enemy) end
        for i, e in ipairs(Core.enemies) do
            e:update()
        end
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
        if key == "space" then
            Core.player:shoot(love.timer.getDelta())
        end
    end
end
Core.mousepressed = function(x, y, button, istouch, presses)
    if Core.status == INGAME then
        Core.player:shoot(love.timer.getDelta())
    end
end


return Core
