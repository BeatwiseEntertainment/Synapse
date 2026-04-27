local Note = class:extend("Note")

function Note:__construct(time, lane, type, prevNote)
    self.x = 2000
    self.y = 0
    self.w = 48
    self.h = 48
    self.lane = lane
    self.time = time
    self.type = type
    self.angle = 0
    self.wasHit = false
    self.mustHit = true
    self.canBeHit = false
    self.visible = false
    self.sustain = {}
    self.sustainTime = sustainTime
    self.sustain.visible = false
    self.previous = prevNote or self

    self.frame = 1
    self.quads = {}
    self.img = nil
    self.scale = 4.5
    self.timer = 0

    self.hitbox = {
        active = false,
        x = self.x,
        y = self.y,
        r = 52,
        hittedByHitbox = false,
    }
end

function Note:checkCollisionHit(obj)
    if self.hitbox and self.hitbox.active then
        return collision.circRect(self.hitbox, obj)
    end
end

function Note:_drawHitbox()
    if FEATURE_FLAGS.developerMode then
        if self.hitbox and not self.hitbox.active then return end

        love.graphics.setColor(1, 0, 0, 0.6)
        love.graphics.circle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.r)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Note:draw()
    local _, _, qw, qh = self.quads[1]:getViewport()
    love.graphics.draw(self.img, self.quads[self.frame], self.x, self.y, 0, self.scale, self.scale, qw * 0.5, qh * 0.5)
end

function Note:update(elapsed)
    --self.timer = self.timer - elapsed

    self.timer = self.timer + elapsed

    if self.timer >= 1 / 18 then
        self.frame = self.frame + 1
        if self.frame > #self.quads then
            self.frame = 1
        end
        self.timer = 0
    end
end

return Note
