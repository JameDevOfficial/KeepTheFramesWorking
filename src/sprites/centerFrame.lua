local M = {}
M.__index = M


-- "fan" mode starts with first point in the center, last point connects back to first point (not center point)
local function createStarVertices(cx, cy, outerRadius, innerRadius, points)
    local vertices = {}
    local angleStep = 2 * math.pi / (points * 2)
    table.insert(vertices, { cx, cy })
    local firstCord = nil
    for i = 1, points * 2 do
        local angle = (i - 1) * angleStep
        local radius = (i % 2 == 1) and outerRadius or innerRadius
        local x = cx + math.cos(angle) * radius
        local y = cy + math.sin(angle) * radius
        if firstCord == nil then firstCord = { x, y } end
        table.insert(vertices, { x, y })
    end
    table.insert(vertices, firstCord)
    return vertices
end

function M:new(opts)
    opts                = opts or {}
    local o             = setmetatable({}, self)
    o.type              = "centerFrame"
    o.size              = opts.size or Settings.centerFrame.size
    o.color             = opts.color or { 1, 1, 1, 1 }
    o.position          = opts.position or { x = Core.screen.centerX, y = Core.screen.centerY }
    o.rotation          = opts.rotation or 0
    o.rotationSpeed     = opts.rotationSpeed or .5
    o.colorIndex        = 1
    o.colorChangeSpeed  = opts.colorChangeSpeed or 1
    o.gradientDirection = 1

    local w_2           = o.size.w / 2
    local h_2           = o.size.h / 2
    local points        = 13
    local outerRadius   = w_2
    local innerRadius   = w_2 + 5
    o.shape             = createStarVertices(0, 0, outerRadius, innerRadius, points)

    if opts.world then
        o.body = love.physics.newBody(opts.world, o.position.x, o.position.y, "static")
        ---@diagnostic disable-next-line: deprecated
        o.mesh = love.graphics.newMesh(points * 2 + 2, "fan", "static")
        o.mesh:setVertices(o.shape)
        o.body:setAngle(o.rotation)
    end
    return o
end

function M:update(dt)
    self.body:setAngle(self.body:getAngle() + self.rotationSpeed * dt)

    local speed = self.colorChangeSpeed * dt
    self.gradientDirection = self.gradientDirection + speed

    self.color[1] = 0.5 + 0.5 * math.sin(self.gradientDirection)
    self.color[2] = 0.5 + 0.5 * math.sin(self.gradientDirection + 2 * math.pi / 3)
    self.color[3] = 0.5 + 0.5 * math.sin(self.gradientDirection + 4 * math.pi / 3)

    local mx, my = love.mouse.getPosition()
    local cx, cy = self.body:getPosition()
    local dx, dy = mx - cx, my - cy
    local r = math.sqrt(dx * dx + dy * dy)
    self.scale = (r / math.max(Core.screen.X, Core.screen.Y)) * 2 + 1
end

function M:render()
    love.graphics.push();
    love.graphics.setLineWidth(2)
    love.graphics.translate(self.body:getX(), self.body:getY())
    love.graphics.rotate(self.body:getAngle())
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(2)
    local meshCenterX = 0
    local meshCenterY = 0
    local scale = self.scale or 1.5 -- Increase scale, default to 1.5 if not set
    love.graphics.draw(self.mesh, meshCenterX, meshCenterY, 0, scale, scale)
    love.graphics.pop()
end

return M
