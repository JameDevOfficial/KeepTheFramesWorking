Core = require("game.core")
Settings = require("game.settings")
UI = require("game.ui")
-- Sprites
Player = require("sprites.player")
Enemy = require("sprites.enemy")
CF = require("sprites.centerFrame")


function love.load()
    Core.load()
end

function love.update(dt)
    Core.update(dt)
end

function love.draw()
    UI.draw()
end

function love.resize()
    Core.screen = UI.windowResized()
end

function love.keypressed(key, scancode, isrepeat)
    Core.keypressed(key,scancode,isrepeat)
end

function love.keyreleased(key, scancode)

end

