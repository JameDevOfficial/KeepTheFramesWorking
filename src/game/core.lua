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
    Core.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
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

local function beginContact(a, b, coll)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
    local t1 = u1 and u1.type
    local t2 = u2 and u2.type

    if (t1 == "projectile" and t2 == "centerFrame") or
        (t2 == "projectile" and t1 == "centerFrame") then
        if u1.type == "centerFrame" then
            u1.collisionHappened = true
            print("centerFrame found and coll set to true")
        elseif u2.type == "centerFrame" then
            u2.collisionHappened = true
            print("centerFrame found and coll set to true")
        end
        if u1.type == "projectile" then
            u1:destroy()
        elseif u2.type == "projectile" then
            u2:destroy()
        end
    end
end

local function endContact(a, b, coll)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
end

local function preSolve(a, b, coll)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
end

local function postSolve(a, b, coll, normalimpulse, tangentimpulse)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
end


return Core
