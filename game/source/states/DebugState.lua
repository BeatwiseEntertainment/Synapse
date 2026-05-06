DebugState = {}

local colors = {
    fg = { lume.color("#ffb84a") },
    bg = { lume.color("#0e0421") }
}

function DebugState:enter()
    self.areas = {
        ["leftTouchArea"] = {
            x = 0,
            y = 0,
            w = shove.getViewportWidth() * 0.5,
            h = shove.getViewportHeight() - 180,
            active = false,
            color = { lume.color("#dc3ff33") }
        },
        ["rightTouchArea"] = {
            x = shove.getViewportWidth() * 0.5,
            y = 0,
            w = shove.getViewportWidth() * 0.5,
            h = shove.getViewportHeight() - 180,
            active = false,
            color = { lume.color("#D5CF0D64") }
        },
        ["middleTouchArea"] = {
            x = 0,
            y = shove.getViewportHeight() - 180,
            w = shove.getViewportWidth(),
            h = shove.getViewportHeight() - 180,
            active = false,
            color = { lume.color("#ffffff") }
        }
    }
end

function DebugState:draw()

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
