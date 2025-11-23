---@diagnostic disable: deprecated
local M = {}
M.__index = M

local enemyFonts = {
    love.graphics.newFont(Settings.fonts.courierPrimeCode, 28),
    love.graphics.newFont(Settings.fonts.courierPrimeCode, 30),
    love.graphics.newFont(Settings.fonts.courierPrimeCode, 32),
    love.graphics.newFont(Settings.fonts.courierPrimeCode, 34),
    love.graphics.newFont(Settings.fonts.courierPrimeCode, 36),
    love.graphics.newFont(Settings.fonts.courierPrimeCode, 38),
    love.graphics.newFont(Settings.fonts.courierPrimeCode, 40),
    love.graphics.newFont(Settings.fonts.courierPrimeCode, 42),
}

function M:new(opts)
    opts             = opts or {}
    local o          = setmetatable({}, self)
    local brightness = opts.brightness or 1
    local saturation = math.random(10, 70) / 100
    o.type           = "enemy"
    o.scale          = opts.scale or math.random(1, 8)
    o.color          = opts.color or { saturation, 1, saturation, brightness }
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
    o.distance       = 1
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

        local ex, ey = o.body:getPosition()
        local cx, cy = Core.centerFrame.body:getPosition()
        local dx, dy = ex - cx, ey - cy
        o.distance = math.sqrt(dx * dx + dy * dy)

        local targetX = Core.screen.centerX
        local targetY = Core.screen.centerY
        local angle = math.atan2(targetY - o.position.y, targetX - o.position.x)
        local speed = math.random(Settings.enemy.speed - Settings.enemy.speedOffset,
            Settings.enemy.speed + Settings.enemy.speedOffset)
        o.body:setLinearVelocity(math.cos(angle) * speed, math.sin(angle) * speed)

        local w = enemyFonts[o.scale]:getWidth(o.text)
        local h = enemyFonts[o.scale]:getHeight()
        o.shape = love.physics.newRectangleShape(w, h)
        o.fixture = love.physics.newFixture(o.body, o.shape)
        o.fixture:setUserData(o)
        o.fixture:setFilterData(Settings.collision.enemy, Settings.collision.projectile + Settings.collision.centerFrame,
            0)
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
    love.graphics.setFont(enemyFonts[self.scale])
    local w, h = enemyFonts[self.scale]:getWidth(self.text), enemyFonts[self.scale]:getHeight()
    local s = 1
    if Core.status ~= INGAME then
        s = 0.5 + (self.distance / (Core.screen.X / 2) + self.distance / (Core.screen.Y / 2)) / 2
    end
    local drawX = -w / 2 * s
    local drawY = -h / 2 * s
    love.graphics.print(self.text, drawX, drawY, 0, s, s)
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
    local ex, ey = self.body:getPosition()
    local cx, cy = Core.centerFrame.body:getPosition()
    local dx, dy = ex - cx, ey - cy
    self.distance = math.sqrt(dx * dx + dy * dy)
end

function M:handleCollision()
    self:destroy()
end

function M:destroy()
    if self.fixture then
        pcall(function()
            self.fixture:setUserData(nil)
            self.fixture:destroy()
        end)
        self.fixture = nil
    end
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

local spawnTimer = 0
function M:spawnRandom(dt, spawnDelay, brightness)
    local spawnDelay = spawnDelay or Settings.enemy.spawnDelay
    local bright = brightness or nil
    spawnTimer = spawnTimer and spawnTimer + dt or 0 + dt
    if spawnTimer < spawnDelay / (math.floor(Player.points / Settings.enemy.harderDelay) + 1) then
        return
    end
    spawnTimer = 0
    local spawn = math.random(1, 100) > Settings.enemy.spawnChance
    if not spawn then return end
    return M:new({ world = Core.world, brightness = bright })
end

return M
