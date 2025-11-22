local player = {}

player.__index = player
player.points = 0

function player:new(opts)
    opts       = opts or {}
    local o    = setmetatable({}, self)
    o.type     = "player"
    o.size     = opts.size or Settings.player.size
    o.color    = opts.color or { 1, 1, 1, 1 }
    o.position = opts.position or { x = Core.screen.centerX, y = Core.screen.centerY }
    o.velocity = opts.velocity or { x = 0, y = 0 }
    o.damping  = opts.damping or 0.5
    o.rotation = opts.rotation or -math.pi / 2
    o.offset   = opts.offset or { x = 0, y = 0 }
    o.scale    = opts.scale or { w = 1, y = 1 }

    local w_2  = o.size.w / 2
    local h_2  = o.size.h / 2

    o.shape    = {
        w_2, 0,
        -w_2, -h_2,
        -(o.size.w / 4), 0,
        -w_2, h_2
    }

    if opts.world then
        o.body = love.physics.newBody(opts.world, o.position.x, o.position.y, "dynamic")
        o.body:setLinearDamping(o.damping)
        ---@diagnostic disable-next-line: deprecated
        o.fixture = love.physics.newPolygonShape(unpack(o.shape))
        o.collision = love.physics.newFixture(o.body, o.fixture)
        o.collision:setUserData(o)
        o.body:setAngle(o.rotation)
    end
    return o
end

function player:update()

end

function player:render()
    love.graphics.push();
    love.graphics.setLineWidth(2)
    love.graphics.translate(self.body:getX(), self.body:getY())
    love.graphics.rotate(self.body:getAngle())
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(2)

    love.graphics.polygon("line", self.shape)
    if Settings.DEBUG then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.line(0, 0, 30, 0)
    end

    love.graphics.pop()
end

return player
