local Player = {}

function Player:init(x, y)
    self.img = nil
    self.centerOffset = false
    self.x = x
    self.y = y
    self.scale = 2
    self.oldY = y
    self.hitbox = {}
    self.hitbox.x = self.x
    self.hitbox.y = self.y
    self.hitbox.w = 0
    self.hitbox.h = 0
    self.hitbox.offsetX = 0
    self.hitbox.offsetY = 0
    self.isJumping = false
    self.isJumping = false
    self.jumpProgress = 0
    self.jumpDuration = 0

    self.timer = 0
    self.frame = 1
    self.quads = {}
    self.state = "idle"

    self.jumpHeight = 128
end

function Player:updateHitbox()
    self.hitbox.w = self.img:getWidth() * self.scale
    self.hitbox.h = self.img:getHeight() * self.scale
end

function Player:_drawHitbox()
    if FEATURE_FLAGS.developerMode then
        if type(self.hitbox) == "nil" then return end

        love.graphics.setColor(1, 0, 0, 0.6)
        love.graphics.rectangle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.w, self.hitbox.h)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Player:draw()
    if not self.img then return end
    local _, _, qw, qh = self.quads["jump"]:getViewport()
    love.graphics.draw(self.img, self.quads[self.state == "idle" and "idle" .. self.frame or "jump"], self.x, self.y, 0, self.scale, self.scale, qw / 2, qh / 2)
end

function Player:update(conductor, elapsed)
    if type(self.hitbox) == "nil" then return end
    self.hitbox.x = self.x + self.hitbox.offsetX
    self.hitbox.y = self.y + self.hitbox.offsetY

    local beatProgress = (conductor.songPos % conductor.crochet) / conductor.crochet

    if self.state == "idle" then
        self.frame = math.floor(beatProgress * 3) + 1
    end

    if self.isJumping then
        self.jumpProgress = self.jumpProgress + elapsed

        local t = self.jumpProgress / self.jumpDuration

        if t >= 1 then
            self.isJumping = false
            self.state = "idle"
            self.y = self.oldY
            return
        end

        self.y = self.oldY - math.sin(t * math.pi) * self.jumpHeight
    end
end

function Player:jump(conductor)
    if self.isJumping then return end

    if self.isJumping then return end

    self.jumpDuration = conductor.crochet / 1000
    self.jumpProgress = 0
    self.state = "jump"
    self.isJumping = true
end

return Player