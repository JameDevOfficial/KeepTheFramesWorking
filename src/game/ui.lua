local UI = {}

local fontDefault = love.graphics.newFont(20)
local font30 = love.graphics.newFont(30)
local font50 = love.graphics.newFont(50)
local titleFont = love.graphics.newFont(Settings.fonts.quirkyRobot, 128, "normal", love.graphics.getDPIScale())
local textFont = love.graphics.newFont(Settings.fonts.semiCoder, 32, "normal", love.graphics.getDPIScale())

titleFont:setFilter("nearest", "nearest")
textFont:setFilter("nearest", "nearest")
fontDefault:setFilter("nearest", "nearest")
font30:setFilter("nearest", "nearest")
font50:setFilter("nearest", "nearest")

UI.draw = function()
    Core.player:render()
    Core.centerFrame:render()
    love.graphics.setFont(textFont)
    -- FPS Label
    local fps = love.timer.getFPS()
    if fps < 1 / love.timer.getAverageDelta() then
        love.graphics.setColor(1, 0.4, 0.4)
    elseif fps > 1 / love.timer.getAverageDelta() then
        love.graphics.setColor(0.4, 1, 0.4)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    local text = string.format("FPS: %03d", love.timer.getFPS())
    local x, y = Core.screen.X - textFont:getWidth(text) - 10, 10
    love.graphics.print(text, x, y)

    -- Time Label
    love.graphics.setColor(1, 1, 1)
    local minutes = math.floor(Player.points / 60)
    local seconds = Player.points - minutes * 60
    text = string.format("%02d:%02d", minutes, seconds)
    local x, y = Core.screen.X - textFont:getWidth(text) - 10, textFont:getHeight() + 10
    love.graphics.print(text, x, y)

    -- Frame specific
    if Core.status == INMENU then
        UI.drawMenu()
    elseif Core.status == INGAME then
        UI.drawGame()
    end

    if Settings.DEBUG then
        UI.drawDebug()
    end
end

UI.drawGame = function()
    for i, enemy in ipairs(Core.enemies) do
        enemy:render()
    end
end

UI.drawMenu = function()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(titleFont)
    local text = "Keep the Frames working"
    local width = titleFont:getWidth(text)
    love.graphics.print(text, (Core.screen.X - width) / 2, Core.screen.centerY - 200)

    local minutes = math.floor(Player.points / 60)
    local seconds = Player.points - minutes * 60
    text = string.format("Survived: %02d:%02d min", minutes, seconds)
    love.graphics.setFont(textFont)
    love.graphics.setColor(1, 1, 1)
    width = textFont:getWidth(text)
    local height = textFont:getHeight()
    love.graphics.print(text, (Core.screen.X - width) / 2, Core.screen.centerY - 100)

    text = "Press 'enter' to start"
    love.graphics.setFont(textFont)
    love.graphics.setColor(1, 1, 1)
    width = textFont:getWidth(text)
    local height = textFont:getHeight()
    love.graphics.print(text, (Core.screen.X - width) / 2, (Core.screen.centerY - height) * 2)
end

UI.drawDebug = function()
    if Settings.DEBUG == true then
        love.graphics.setFont(fontDefault)

        local y = fontDefault:getHeight() + 10

        love.graphics.setColor(1, 0.1, 0.1)
        love.graphics.print("Disable (F5) Debug Mode for more FPS")
        y = y + fontDefault:getHeight()

        love.graphics.setColor(1, 1, 1, 1)
        -- FPS
        local fps = love.timer.getFPS()
        local fpsText = string.format("FPS: %d", fps)
        love.graphics.print(fpsText, 10, y)
        y = y + fontDefault:getHeight()

        -- Performance
        local stats = love.graphics.getStats()
        local usedMem = collectgarbage("count")
        local perfText = string.format(
            "Memory: %.2f MB\n" ..
            "GC Pause: %d%%\n" ..
            "Draw Calls: %d\n" ..
            "Canvas Switches: %d\n" ..
            "Texture Memory: %.2f MB\n" ..
            "Images: %d\n" ..
            "Fonts: %d\n",
            usedMem / 1024,
            collectgarbage("count") > 0 and collectgarbage("count") / 7 or 0,
            stats.drawcalls,
            stats.canvasswitches,
            stats.texturememory / 1024 / 1024,
            stats.images,
            stats.fonts
        )
        love.graphics.print(perfText, 10, y)
        y = y + fontDefault:getHeight() * 8

        -- Game
        local dt = love.timer.getDelta()
        local avgDt = love.timer.getAverageDelta()
        local projCount = (Player and Player.ship and Player.ship.projectiles and type(Player.ship.projectiles) == "table") and
            #Player.ship.projectiles or 0
        local numComets = (type(Core.enemies) == "table") and #Core.enemies or 0
        local posX, posY = 0, 0
        local velX, velY = 0, 0
        local shipAngle = 0
        if Player and Player.ship and Player.ship.body then
            posX, posY = Player.ship.body:getPosition()
            velX, velY = Player.ship.body:getLinearVelocity()
            shipAngle = Player.ship.body:getAngle()
        end
        local playerText = string.format(
            "Game state: %s\n" ..
            "Delta Time: %.4fs (%.1f ms)\n" ..
            "Avg Delta: %.4fs (%.1f ms)\n" ..
            "Time: %.2fs\n" ..
            "Enemies: %d\n" ..
            "Projectiles: %d\n" ..
            "Player Rotation: %f",
            tostring(Core.status),
            dt, dt * 1000,
            avgDt, avgDt * 1000,
            love.timer.getTime(),
            numComets,
            projCount,
            shipAngle
        )
        love.graphics.print(playerText, 10, y)
        y = y + fontDefault:getHeight() * 8

        -- System Info
        local renderer = love.graphics.getRendererInfo and love.graphics.getRendererInfo() or ""
        local systemText = string.format(
            "OS: %s\nGPU: %s",
            love.system.getOS(),
            select(4, love.graphics.getRendererInfo()) or 0
        )
        love.graphics.print(systemText, 10, y)
    end
end

UI.windowResized = function()
    local screen = {
        X = 0,
        Y = 0,
        centerX = 0,
        centerY = 0,
        minSize = 0,
        topLeft = { X = 0, Y = 0 },
        topRight = { X = 0, Y = 0 },
        bottomLeft = { X = 0, Y = 0 },
        bottomRight = { X = 0, Y = 0 }
    }
    screen.X, screen.Y = love.graphics.getDimensions()
    screen.minSize = (screen.Y < screen.X) and screen.Y or screen.X
    screen.centerX = screen.X / 2
    screen.centerY = screen.Y / 2

    local half = screen.minSize / 2
    screen.topLeft.X = screen.centerX - half
    screen.topLeft.Y = screen.centerY - half
    screen.topRight.X = screen.centerX + half
    screen.topRight.Y = screen.centerY - half
    screen.bottomRight.X = screen.centerX + half
    screen.bottomRight.Y = screen.centerY + half
    screen.bottomLeft.X = screen.centerX - half
    screen.bottomLeft.Y = screen.centerY + half

    return screen
end

return UI
