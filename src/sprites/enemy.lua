---@diagnostic disable: deprecated
local M = {}
M.__index = M

local enemyFont = love.graphics.newFont(Settings.fonts.courierPrimeCode, 30, "normal", love.graphics.getDPIScale())
print(enemyFont:getLineHeight())
function M:new(opts)
    opts    = opts or {}
    local o = setmetatable({}, self)
    o.type  = "enemy"
    o.scale = opts.scale or math.random(0.5, 2)
    o.color = opts.color or { 0.7, 1, 0.7, 1 }
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
    o.rotation       = opts.rotation or 0
    o.offset         = opts.offset or { x = 0, y = 0 }
    local textLength = math.random(4, 10) + math.floor(Player.points / Settings.enemy.harderDelay)
    o.text           = ""
    for i = 1, textLength, 1 do
        o.text = o.text .. math.random(0, 1)
    end

    if opts.world then
        o.body = love.physics.newBody(opts.world, o.position.x, o.position.y, "dynamic")
        local angle = math.atan2(Core.screen.centerY - o.position.y, Core.screen.centerX - o.position.x)
        angle = (angle + math.pi) % (2 * math.pi) - math.pi
        if angle > math.pi / 2 or angle < -math.pi / 2 then
            angle = angle + math.pi
        end
        o.body:setAngle(angle)

        local targetX = Core.screen.centerX
        local targetY = Core.screen.centerY
        local angle = math.atan2(targetY - o.position.y, targetX - o.position.x)
        local speed = math.random(Settings.enemy.speed - Settings.enemy.speedOffset,
        Settings.enemy.speed + Settings.enemy.speedOffset)
        o.body:setLinearVelocity(math.cos(angle) * speed, math.sin(angle) * speed)

        local w = enemyFont:getWidth(o.text)
        local h = enemyFont:getHeight()
        o.shape = love.physics.newRectangleShape(w, h)
        o.fixture = love.physics.newFixture(o.body, o.shape)
        o.fixture:setUserData(o)
o.fixture:setFilterData(Settings.collision.enemy, Settings.collision.projectile + Settings.collision.centerFrame, 0)
    end
    return o
end

function M:render()
    love.graphics.push();
    love.graphics.setLineWidth(2)
    love.graphics.translate(self.body:getX() + self.offset.x, self.body:getY() + self.offset.y)
    love.graphics.rotate(self.body:getAngle())
    love.graphics.setColor(self.color)
    local oldFont = love.graphics.getFont()
    love.graphics.setFont(enemyFont)
    local w, h = enemyFont:getWidth(self.text), enemyFont:getHeight()
    love.graphics.print(self.text, -w / 2, -h / 2)
    if Settings.DEBUG then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.line(-10, 0, 10, 0, 0, 0, 0, 10, 0, -10)
    end

    love.graphics.pop()
    love.graphics.setFont(oldFont)
end

function M:update()
    if self.collisionHappened then
        self:handleCollision()
        self.collisionHappened = nil
        if not self.body then return end
    end
end

function M:handleCollision()
    self:destroy()
end

function M:destroy()
    if self.collision then
        self.collision:destroy()
        self.collision = nil
    end
    if self.body then
        self.body:destroy()
        self.body = nil
    end

    if Core.enemies then
        for i = 1, #Core.enemies do
            if Core.enemies[i] == self then
                table.remove(Core.enemies, i)
                break
            end
        end
    end
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
