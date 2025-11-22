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
    --Core.player:render()
    Core.centerFrame:render()

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
end

UI.drawGame = function()

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
