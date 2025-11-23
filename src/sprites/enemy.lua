local M = {}
M.__index = M

local enemyFont = love.graphics.newFont(Settings.fonts.courierPrimeCode, 30, "normal", love.graphics.getDPIScale())
function M:new(opts)
    opts    = opts or {}
    local o = setmetatable({}, self)
    o.type  = "enemy"
    o.size  = opts.size or Settings.player.size
    o.color = opts.color or { 0.8, 1, 0.8, 1 }
    if not opts.position then
        local randPos = math.random(1, 2)
        if randPos == 1 then
            o.position = { x = math.random(0, Core.screen.X), y = (math.random(1, 2) == 1 and 0 or Core.screen.Y) }
        else
            o.position = { x = (math.random(1, 2) == 1 and 0 or Core.screen.X), y = math.random(0, Core.screen.Y) }
        end
    else
        o.position = opts.position
    end
    o.rotation = opts.rotation or 0
    o.offset   = opts.offset or { x = 0, y = 0 }
    o.text     = "110101" -- placeholder

    if opts.world then
        o.body = love.physics.newBody(opts.world, o.position.x, o.position.y, "dynamic")
        o.body:setAngle(o.rotation)

        local targetX = Core.screen.centerX
        local targetY = Core.screen.centerY
        ---@diagnostic disable-next-line: deprecated
        local angle = math.atan2(targetY - o.position.y, targetX - o.position.x)
        o.body:setLinearVelocity(math.cos(angle) * Settings.enemy.speed, math.sin(angle) * Settings.enemy.speed)
        o.body:setAngularVelocity(math.random(-1, 1))
    end
    return o
end

function M:render()
    print("Rendering enemy")
    love.graphics.push();
    love.graphics.setLineWidth(2)
    love.graphics.translate(self.body:getX() + self.offset.x, self.body:getY() + self.offset.y)
    love.graphics.rotate(self.body:getAngle())
    love.graphics.setColor(self.color)
    local oldFont = love.graphics.getFont()
    love.graphics.setFont(enemyFont)
    love.graphics.print(self.text)
    if Settings.DEBUG then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.line(0, 0, 30, 0)
    end

    love.graphics.pop()
    love.graphics.setFont(oldFont)
end

function M:update()

end

function M:spawnRandom(dt)
    self.spawnTimer = self.spawnTimer and self.spawnTimer + dt or 0 + dt
    if self.spawnTimer < Settings.enemy.spawnDelay then
        return
    end
    self.spawnTimer = 0
    local spawn = math.random(1, 100) > Settings.enemy.spawnChance
    if not spawn then return end
    return M:new({ world = Core.world })
end

return M
