local Judment = class:extend("Judment")

function Judment:__construct(img, quad, x, y, scale)
    self.type = "judment"
    self.img = img
    self.quad = quad
    self.x = x
    self.y = y
    self.scale = 0
    self.targetScale = scale
    self.destroy = false

    -- when create the judment sprite, apply the flux tween effect --
    flux.to(self, 0.5, { scale = self.targetScale, y = self.y - 16 })
        :ease("backinout")
        :oncomplete(function()
            flux.to(self, 2, { scale = 0, y = shove.getViewportHeight() })
                :ease("backinout")
                :oncomplete(function() self.destroy = true end)
        end)
end

function Judment:draw()
    local _, _, qw, qh = self.quad:getViewport()
    love.graphics.draw(self.img, self.quad, self.x, self.y, 0, self.scale, self.scale, qw * 0.5, qh * 0.5)
end

return Judment