local ComboCounter = class:extend("ComboCounter")

local Digit = class:extend("Digit")

function Digit:__construct(digit, x, y)
    self.digit = 0
    self.img = nil
    self.quad = nil
    self.x = x
    self.y = y
    self.scale = 1
    self.fadeTime = 1.25
    self.destroy = false
end

function Digit:draw()
    local _, _, qw, qh = self.quad:getViewport()
    love.graphics.draw(self.img, self.quad, self.x, self.y, 0, self.scale, self.scale, qw * 0.5, qh * 0.5)
end

function Digit:update(elapsed)

end

function ComboCounter:__construct(assets, x, y)
    self.x = x or 0
    self.y = y or 0
    self.img = assets.img
    self.quads = assets.quads
    self.count = 0
    self.digits = {}
    self.scale = 3
end

function ComboCounter:createDigits(num)
    local strnum = tostring(num)
    local i = 0
    for d in strnum:gmatch(".") do
        local q = self.quads["num000" .. d]
        local _, _, qw, qh = q:getViewport()
        local digit = Digit:new(tonumber(d), self.x + qw * self.scale * i, self.y)
        digit.img = self.img
        digit.quad = q
        digit.scale = self.scale
        flux.to(digit, digit.fadeTime, { scale = 0, y = shove.getViewportHeight() + 32 })
            :ease("backinout")
            :delay(1.5)
            :oncomplete(function()
                destroy = true
            end)

        table.insert(self.digits, digit)
        i = i + 1
    end
    --local digit = Digit:new()
end

function ComboCounter:draw()
    for _, d in ipairs(self.digits) do
        d:draw()
    end
end

function ComboCounter:update(elapsed)
    for _, d in ipairs(self.digits) do
        if d.destroy then
            table.remove(self.digits, _)
        end
    end
end

return ComboCounter