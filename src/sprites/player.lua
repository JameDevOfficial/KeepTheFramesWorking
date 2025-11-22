local player = {}
player.__index = player
player.points = 0

function player:new(opts)
    opts          = opts or {}
    local o       = setmetatable({}, self)
    o.type        = "player"
    o.size        = opts.size or Settings.player.size
    o.color       = opts.color or { 1, 1, 1, 1 }
    o.position    = opts.position or { x = Core.screen.centerX, y = Core.screen.centerY }
    o.damping     = opts.damping or 0.5
    o.rotation    = opts.rotation or 0
    o.offset      = opts.offset or { x = 0, y = 0 }
    o.projectiles = {}

    local w_2     = o.size.w / 2
    local h_2     = o.size.h / 2

    o.shape       = {
        w_2 / 2, -h_2 / 3,
        w_2 * 2, -h_2 / 5,
        w_2 * 2, h_2 / 5,
        w_2 / 2, h_2 / 3,
        0, h_2 / 2,
        0, -h_2 / 2,
    }

    if opts.world then
        o.body = love.physics.newBody(opts.world, o.position.x, o.position.y, "dynamic")
        o.body:setLinearDamping(o.damping)
        ---@diagnostic disable-next-line: deprecated
        o.body:setAngle(o.rotation)
    end
    return o
end

function player:checkMovement(dt)
    if Core.status == INGAME then
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            self:rotate(-dt * 3)
        end

        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            self:rotate(dt * 3)
        end
    end
end

function player:shoot(dt)
    local projectile = {}
    projectile.type = "projectile"
    projectile.size = { w = 25, h = 3 }
    projectile.body = love.physics.newBody(Core.world, self.body:getX(), self.body:getY(), "dynamic")
    projectile.fixture = love.physics.newRectangleShape(projectile.size.w, projectile.size.h)
    projectile.collision = love.physics.newFixture(projectile.body, projectile.fixture)
    projectile.collision:setUserData(projectile)
    projectile.collision:setFilterData(Settings.collision.projectile, Settings.collision.enemy, 0)
    local player = self

    function projectile:destroy()
        if self.body then
            self.body:destroy()
            self.body = nil
        end
        for i, p in ipairs(player.projectiles) do
            if p == self then
                table.remove(player.projectiles, i)
                break
            end
        end
    end

    local angle = self.body:getAngle()
    projectile.body:setAngle(angle)

    local forceX = math.cos(angle) * Settings.player.projectileSpeed * dt
    local forceY = math.sin(angle) * Settings.player.projectileSpeed * dt
    projectile.body:applyLinearImpulse(forceX, forceY)

    table.insert(self.projectiles, projectile)
end

function player:render()
    love.graphics.push();
    love.graphics.setLineWidth(2)
    love.graphics.translate(self.body:getX() + self.offset.x, self.body:getY() + self.offset.y)
    love.graphics.rotate(self.body:getAngle())
    love.graphics.setColor(self.color)
    love.graphics.polygon("fill", self.shape)
    if Settings.DEBUG then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.line(0, 0, 30, 0)
    end

    love.graphics.pop()

    for _, projectile in ipairs(self.projectiles) do
        love.graphics.push()
        love.graphics.translate(projectile.body:getX(), projectile.body:getY())
        love.graphics.rotate(projectile.body:getAngle())
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", -projectile.size.w / 2, -projectile.size.h / 2, projectile.size.w,
            projectile.size.h)
        love.graphics.pop()
    end
end

function player:destroy()
    if self.body then
        self.body:destroy()
        self.body = nil
    end
end

function player:update(dt)
    Core.player:checkMovement(dt)

    for i = #self.projectiles, 1, -1 do
        local p = self.projectiles[i]
        if p.body then
            local x, y = p.body:getX(), p.body:getY()

            if x < -50 or x > Core.screen.X + 50 or y < -50 or y > Core.screen.Y + 50 then
                p:destroy()
            end
        end
    end
end

function player:rotate(amount)
    if self.body then
        self.body:setAngle(self.body:getAngle() + amount)
    else
        self.rotation = self.rotation + amount
    end
end

return player
