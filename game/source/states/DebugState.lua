DebugState = {}

local colors = {
    fg = { lume.color("#ffb84a") },
    bg = { lume.color("#0e0421") }
}

function DebugState:enter()
    self.areas = {
        leftTouchArea = {
            x = 0,
            y = 0,
            w = shove.getViewportWidth() * 0.5,
            h = shove.getViewportHeight(),
            active = false,
            color = { lume.color("#dc3ff33") }
        },
        rightTouchArea = {
            x = shove.getViewportWidth() * 0.5,
            y = 0,
            w = shove.getViewportWidth() * 0.5,
            h = shove.getViewportHeight(),
            active = false,
            color = { lume.color("#D5CF0D64") }
        }
    }
end

function DebugState:draw()
    love.graphics.print("Current touches on screen: " .. #love.touch.getTouches(), 30, 30)

    --love.graphics.rectangle(self.testButton.active and "fill" or "line", self.testButton.x, self.testButton.y, self.testButton.w, self.testButton.h)
    for key, rect in pairs(self.areas) do
        love.graphics.setColor(rect.color)
        love.graphics.rectangle(rect.active and "fill" or "line", rect.x, rect.y, rect.w, rect.h)
        love.graphics.setColor(1, 1, 1, 1)
    end

    for i, id in ipairs(love.touch.getTouches()) do
        local tx, ty       = love.touch.getPosition(id)
        local inside, x, y = shove.screenToViewport(tx, ty)
        love.graphics.circle("fill", x, y, 20)
    end
end

function DebugState:update(elapsed)

end

function DebugState:touchpressed(id, x, y, dx, dy, pressure)
    local inside, px, py = shove.screenToViewport(x, y)
    if collision.pointRect({ x = px, y = py }, self.areas.rightTouchArea) then
        self.areas.rightTouchArea.active = true
    end
    if collision.pointRect({ x = px, y = py }, self.areas.leftTouchArea) then
        self.areas.leftTouchArea.active = true
    end
end

function DebugState:touchreleased(id, x, y, dx, dy, pressure)
    self.areas.leftTouchArea.active = false
    self.areas.rightTouchArea.active = false
end

return DebugState
