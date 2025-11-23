local Core = {}

EXITED = -1
PAUSED = 0
LOADING = 1
INHELP = 5
-- Below are all fine during game
INMENU = 11
INGAME = 12

Core.enemies = {}

Core.reset = function()
    Player.points = 0
    for i, e in pairs(Core.enemies) do
        e:destroy()
    end
    Core.enemies = {}
    Core.world:destroy()
    Core.player:destroyProjectiles()
    if Core.player and Core.player.body then
        pcall(function() Core.player.body:destroy() end)
        Core.player = nil
    end
    if Core.centerFrame and Core.centerFrame.destroy then
        Core.centerFrame:destroy()
        Core.centerFrame = nil
    end

    math.randomseed(os.time())
    Core.world = love.physics.newWorld(0, 0, true)
    Core.world:setCallbacks(Core.beginContact, Core.endContact, Core.preSolve, Core.postSolve)
    Core.screen = UI.windowResized()
    Core.player = Player:new({ color = Settings.player.color, world = Core.world })
    Core.centerFrame = CF:new({ world = Core.world })
end

Core.load = function()
    math.randomseed(os.time())
    Core.status = LOADING

    Core.world = love.physics.newWorld(0, 0, true)
    Core.world:setCallbacks(Core.beginContact, Core.endContact, Core.preSolve, Core.postSolve)
    Core.screen = UI.windowResized()
    Core.player = Player:new({ color = Settings.player.color, world = Core.world })
    Core.centerFrame = CF:new({ world = Core.world })

    Core.status = INMENU
end

Core.update = function(dt)
    if dt > 1 / Settings.centerFrame.criticalFPS then
        Core.centerFrame.sleepPerSecond = 0
        Core.status = INMENU
        Core.reset()
    end
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
    if Core.status == INMENU or Core.status == INHELP then
        local enemy = Enemy:spawnRandom(dt, 0.1, 0.4)
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
    if Core.status == INHELP then
        Core.status = INMENU
        return
    end
    if Core.status == INMENU then
        if key == "return" then
            Core.reset()
            Core.status = INGAME
        end
        if key == "h" or key == "H" then
            Core.status = INHELP
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

function Core.beginContact(a, b, coll)
    --print("Collision")
    local u1 = a:getUserData()
    local u2 = b:getUserData()
    local t1 = u1 and u1.type
    local t2 = u2 and u2.type
    --print(t1, t2)

    if (t1 == "projectile" and t2 == "enemy") or
        (t2 == "projectile" and t1 == "enemy") then
        --print("Collision type 1")
        if u1.type == "enemy" then
            u1.collisionHappened = true
            --print("enemy found and coll set to true")
        elseif u2.type == "enemy" then
            u2.collisionHappened = true
            --print("enemy found and coll set to true")
        end
        if u1.type == "projectile" then
            u1:destroy()
        elseif u2.type == "projectile" then
            u2:destroy()
        end
    end

    if (t1 == "centerFrame" and t2 == "enemy") or
        (t2 == "centerFrame" and t1 == "enemy") then
        --print("Collision type 2")
        if u1.type == "centerFrame" and Core.status == INGAME then
            u1.collisionHappened = true
            print("encenterFrameemy found and coll set to true")
        elseif u2.type == "centerFrame" and Core.status == INGAME then
            u2.collisionHappened = true
            print("centerFrame found and coll set to true")
        end
        if u1.type == "enemy" then
            u1:destroy()
        elseif u2.type == "enemy" then
            u2:destroy()
        end
    end
end

function Core.endContact(a, b, coll)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
end

function Core.preSolve(a, b, coll)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
end

function Core.postSolve(a, b, coll, normalimpulse, tangentimpulse)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
end

return Core
