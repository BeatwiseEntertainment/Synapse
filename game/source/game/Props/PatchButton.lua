local PatchButton = class:extend("PatchButton")

function PatchButton:__construct(img, x, y, w, h)
    self.sprite = nil
    self.quads = {}
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.text = ""

    self.sprite, self.quads = love.graphics.getQuadsFromAtlas(img, 3, 3)
end

function PatchButton:draw()
    love.graphics.draw(self.sprite, self.quads[1], self.x, self.y)
    love.graphics.draw(self.sprite, self.quads[2], self.x + 32, self.y, 0, 32 / self.w, 1)
    love.graphics.draw(self.sprite, self.quads[3], (self.x + self.w) + 32, self.y)
end

function PatchButton:update(elapsed)

end

return PatchButton
