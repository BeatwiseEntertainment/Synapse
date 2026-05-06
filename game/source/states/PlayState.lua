PlayState = {}

local curBeat = 0

local Song = require 'source.game.Song'
local Note = require 'source.game.Note'
local Conductor = require 'source.game.Conductor'
local Event = require 'source.game.Event'
local Player = require 'source.game.Props.Player'
local ComboCounter = require 'source.game.Props.ComboCounter'
local Judment = require 'source.game.Props.Judment'

local colors = {
    fg = { lume.color("#ffb84a") },
    bg = { lume.color("#0e0421") }
}

PlayState.field = {
    x = 200,
    y = shove.getViewportHeight() / 2,
    spacing = 144,
}
PlayState.song = nil
PlayState.songName = "tutorial"

PlayState.rating = {
    ["awesome"] = 0,
    ["perfect"] = 0,
    ["good"] = 0,
    ["ok"] = 0,
    ["miss"] = 0,
}

local function detectHit(self)
    for index, note in ipairs(self.notes) do
        if not note.checkCollisionHit then return end

        if note:checkCollisionHit(Player.hitbox) and not note.hittedByHitbox then
            note.hittedByHitbox = true
            self.playerHealthTarget = self.playerHealthTarget - 50
            self.scoreTarget = self.scoreTarget - 250
            self.combo = 0
            -- hit event --
            self:onPlayerHit()
        end
    end
end

local function repositionateNotes(self)
    for index, note in ipairs(self.notes) do
        if note.type == "saw" then
            note.angle = note.angle - 6 * love.timer.getDelta()
        end

        local diff = note.time - Conductor.songPos
        note.x = self.field.x + diff * 0.45 * self.song.scrollSpeed
        if note.hitbox then
            note.hitbox.y = note.y
            note.hitbox.x = note.x
        end
    end
end

local function generateSong(self)
    table.sort(self.song.notes, function(a, b)
        return a.time < b.time
    end)

    curBeat = 0

    for idx, note in ipairs(self.song.notes) do
        local laneID = 1
        local isSaw = false
        if note.lane == 0 then
            laneID = 1
            isSaw = false
        elseif note.lane == 1 then
            laneID = 2
            isSaw = false
        elseif note.lane == 2 and love.system.getDeviceType() == "desktop" then
            laneID = 2
            isSaw = true
        end


        local n = Note:new(
            note.time + Conductor.offset,
            laneID, isSaw and "saw" or "idle",
            idx > 1 and self.song.notes[idx - 1] or self.song.notes[idx]
        )

        if n.type == "saw" then
            n.hitbox.active = true
        elseif n.type == "idle" then
            n.hitbox.active = false
        end

        n.img = self["hit"].img
        n.quads = self["hit"].quads

        if n.lane == 1 then
            n.y = self.field.y - self.field.spacing
        else
            n.y = self.field.y + self.field.spacing
        end

        table.insert(self.notes, n)
    end

    self.totalNotes = #self.notes

    self.notesGenerated = true
end

local function getJudgement(diff)
    diff = math.abs(diff)

    if diff <= 30 then
        return "awesome", 350
    elseif diff <= 60 then
        return "perfect", 300
    elseif diff <= 90 then
        return "good", 200
    elseif diff <= 120 then
        return "ok", 100
    else
        return "miss", -150
    end
end

local function processHit(self, lane)
    local hitWindow = 120

    for _, note in ipairs(self.notes) do
        if note.lane == lane and not note.wasHit then
            local diff = note.time - Conductor.songPos

            if diff > hitWindow then
                return
            end

            local absDiff = math.abs(diff)

            if absDiff <= hitWindow then
                local judge, score = getJudgement(diff)

                note.wasHit = true
                self.scoreTarget = self.scoreTarget + score

                if judge == "miss" then
                    self.combo = 0
                else
                    self.combo = self.combo + 1
                    local half = shove.getViewportHeight() * 0.5
                    self.comboRender.y = math.random(half - 16, half + 16)
                    self.comboRender:createDigits(self.combo)
                end

                local halfX = shove.getViewportWidth() * 0.5
                local halfY = shove.getViewportHeight() * 0.5 + 200

                table.insert(self.objects, Judment:new(
                    self["judments"].img,
                    self["judments"].quads[judge],
                    math.random(halfX - 32, halfX + 32),
                    math.random(halfY - 8, halfY + 8), 0.76
                ))

                self.rating[judge] = self.rating[judge] + 1

                self.noteHitCount = self.noteHitCount + 1

                self:onNoteHit(judge, note.lane)

                return
            end
        end
    end
end

local function resetNotes(self)
    for _, note in ipairs(self.notes) do
        if note.wasHit then
            note.wasHit = false
        end
    end
    repositionateNotes(self)
end

local function detectMiss(self)
    local hitWindow = 120

    for _, note in ipairs(self.notes) do
        if not note.wasHit and note.type == "idle" then
            local diff = Conductor.songPos - note.time

            if diff > hitWindow then
                note.wasHit = true

                self.rating["miss"] = self.rating["miss"] + 1

                self.combo = 0
                self.scoreTarget = self.scoreTarget - 100
            end
        end
    end
end

local function shakeScreen(self, duration, strength, shakeAngle)
    self.shakeDuration = duration
    self.shakeTime = duration
    self.shakeStrength = strength
    self.shakeAngleStrength = shakeAngle
end

local function getRank(self)
    local acc = self.accuracy
    local miss = self.rating["miss"]
    local health = self.playerHealth

    if acc >= 0.95 then
        return "S"
    elseif acc >= 0.90 then
        return "A"
    elseif acc >= 0.80 then
        return "B"
    elseif acc >= 0.70 then
        return "C"
    elseif acc <= 0.45 then
        return "D"
    elseif acc <= 0.1 then
        return "F"
    end
end

local function updateAccuracy(self)
    local score =
        self.rating.awesome * 1.0 +
        self.rating.perfect * 0.9 +
        self.rating.good * 0.75 +
        self.rating.ok * 0.5 +
        self.rating.miss * 0

    local totalNotes =
        self.rating.awesome +
        self.rating.perfect +
        self.rating.good +
        self.rating.ok +
        self.rating.miss

    self.accuracy = math.max(0, score / totalNotes)
end

local function win(self)
    flux.removeAll()
    self.song:stop()

    self.ratingScreen.ratingLetter = getRank(self):lower()

    self.finished = true
    self.showRating = true
    flux.to(self, 2, { posDitherY = 0 })
end

function PlayState:enter()
    self.ratingScreen = require 'source.states.Substates.RatingSubstate'
    self.pauseScreen = require 'source.states.Substates.PausedSubstate'
    self.gameOverScreen = require 'source.states.Substates.GameOverSubstate'

    local path = "assets/images/"
    self["hit_lane"] = {}

    love.graphics.setDefaultFilter("nearest", "nearest")

    local img = assetManager.getImage("hit_lane")
    self["hit_lane"].img = img
    self["hit_lane"].quads = love.graphics.getQuads(img, love.filesystem.read(path .. "hit_lane.json"), "hash")

    self["scoretxt"] = assetManager.getImage("score_text")

    local img = assetManager.getImage("player")
    self["player"] = {}
    self["player"].img = img
    self["player"].quads = love.graphics.getQuads(img, love.filesystem.read(path .. "player.json"), "hash")
    img = nil

    self["glow"] = assetManager.getImage("glow")
    self["saw"] = assetManager.getImage("saw")
    --self["hit"] = love.graphics.newImage(path .. "hitter.png")

    self.showGameOver = false

    self["particles"] = {}
    local img = assetManager.getImage("particles")
    self["particles"].img = img
    self["particles"].quads = love.graphics.getQuads(img, love.filesystem.read(path .. "particles.json"), "array")

    self["hit"] = {}
    local img = assetManager.getImage("hitter")
    self["hit"].img = img
    self["hit"].quads = love.graphics.getQuads(img, love.filesystem.read(path .. "hitter.json"), "array")
    img = nil

    local img = assetManager.getImage("judments")
    self["judments"] = {}
    self["judments"].img = img
    self["judments"].quads = love.graphics.getQuads(img, love.filesystem.read(path .. "judments.json"), "hash")
    img = nil

    local img = assetManager.getImage("numbers")
    self["numbers"] = {}
    self["numbers"].img = img
    self["numbers"].quads = love.graphics.getQuads(img, love.filesystem.read(path .. "numbers.json"), "hash")
    img = nil
    self["heart"] = assetManager.getImage("heart")

    self.sounds = {}
    self.sounds["hit"] = assetManager.getAudio("sfx_hit")
    self.sounds["jump"] = assetManager.getAudio("sfx_jump")
    self["gradient"] = assetManager.getImage("gradient")

    self.songCompleted = false

    self.dithbg = ditherManager.getBaked("8x8-56")
    self.dithalmost = ditherManager.getBaked("8x8-61")
    self.dithbg:setFilter("nearest", "nearest")

    self.gameLost = false

    self.beginPlay = false
    self.notesGenerated = false

    self.showRating = false
    self.finished = false

    self.touchAreas = {
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

    --self.zoom = 1
    self.notes = {}
    self.combo = 0

    self.comboRender = ComboCounter:new(self["numbers"], shove.getViewportWidth() * 0.5, shove.getViewportHeight() * 0.5)
    self.comboRender.scale = 2

    self.pressedKeys = { false, false }

    love.graphics.setBackgroundColor(colors.bg)

    Event.hook(Conductor, { "beatHit" })
    Conductor.beatHit = function()
        PlayState.beatHit(PlayState)
    end
    self.camera = camera(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)
    self.camera.target = {
        x = self.camera.x,
        y = self.camera.y,
        offsetX = self.camera.x,
        offsetY = self.camera.y,
        zoom = self.camera.scale,
        rot = self.camera.rot
    }

    Conductor.offset = 0

    self.fontPlayAnnouce = assetManager.getFont("monogram", 40)

    self.objects = {} -- stores the effects XD

    self.paused = false

    self.song = Song:new() -- blank song --

    self.playerHealthMax = 250
    self.playerHealth = self.playerHealthMax
    self.playerHealthTarget = self.playerHealth

    self.angleHeart = 0
    self.heartScale = 3

    self.gradientFXpos = 128

    self.rating = {
        ["awesome"] = 0,
        ["perfect"] = 0,
        ["good"] = 0,
        ["ok"] = 0,
        ["miss"] = 0,
    }

    self.shakeDuration = 0
    self.shakeTime = 0
    self.shakeStrength = 0
    self.shakeAngleStrength = 0
    self.shakeAngle = 0
    self.shakeX = 0
    self.shakeY = 0

    self.ratingScreen:load()
    self.pauseScreen:load()
    self.gameOverScreen:load()

    self.accuracy = 100
    self.noteHitCount = 0
    self.totalNotes = 0

    self.posDitherY = shove.getViewportHeight()

    self.score = 0
    self.scoreTarget = 0
    self.scoreFont = fontcache.getFont("monogram", 100)

    self.song:loadFromJson(PlayState.songName)
    self.song:loadAudio(assetManager.getAudio("msc_" .. PlayState.songName))
    self.song.source:setVolume(1)
    Conductor.songPos = 0

    Conductor.bpm = self.song.bpm

    Player:init(self.field.x, (self.field.y + self.field.spacing - 64))
    Player.img = self["player"].img
    Player.quads = self["player"].quads
    Player.state = "idle"
    Player.scale = 4

    Player.hitbox.w = 16 * Player.scale
    Player.hitbox.h = 32 * Player.scale
    Player.hitbox.offsetX = -8 * Player.scale
    Player.hitbox.offsetY = -16 * Player.scale

    generateSong(self)
    repositionateNotes(self)
end

function PlayState:draw()
    self.camera:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)

    local scale = 6

    love.graphics.draw(
        self["hit_lane"].img,
        self["hit_lane"].quads[self.pressedKeys[1] and "press" or "idle"],
        self.field.x, self.field.y - self.field.spacing, 0,
        scale, scale * 0.67, 10, 10
    )

    love.graphics.draw(
        self["hit_lane"].img,
        self["hit_lane"].quads[self.pressedKeys[2] and "press" or "idle"],
        self.field.x, self.field.y + self.field.spacing, 0,
        scale, scale * 0.35, 10, 10
    )

    Player:draw()

    love.graphics.setColor(colors.fg)
    love.graphics.setLineWidth(5)
    love.graphics.line(PlayState.field.x + 96, self.field.y - self.field.spacing, shove.getViewportWidth(), self.field.y - self.field.spacing)
    love.graphics.line(PlayState.field.x + 96, self.field.y + self.field.spacing, shove.getViewportWidth(), self.field.y + self.field.spacing)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)

    for index, note in ipairs(self.notes) do
        if note.x < shove.getViewportWidth() and not note.wasHit then
            love.graphics.draw(self["glow"], note.x, note.y, 0, 3.5, 3.5, self["glow"]:getWidth() / 2, self["glow"]:getHeight() / 2)
            if note.type == "saw" then
                love.graphics.draw(self["saw"], note.x, note.y, note.angle, 3, 3, self["saw"]:getWidth() / 2, self["saw"]:getHeight() / 2)
            else
                --love.graphics.draw(self["hit"], note.x, note.y, 0, 3, 3, self["hit"]:getWidth() / 2, self["hit"]:getHeight() / 2)
                note:draw()
            end
        end
    end

    self.comboRender:draw()

    love.graphics.setColor(1, 1, 1, 1)
    for _, obj in ipairs(self.objects) do
        if obj.type ~= "judment" then
            local _, _, qw, qh = self["particles"].quads[1]:getViewport()
            love.graphics.draw(self["particles"].img, self["particles"].quads[obj.frame], obj.x, obj.y, 0, obj.scale, obj.scale, qw * 0.5, qh * 0.5)
        end
        if not obj.destroy and obj.draw then
            obj:draw()
        end
    end

    self.camera:detach()

    love.graphics.setColor(colors.fg)
    love.graphics.print(string.format("%06d", self.score), self.scoreFont, 300, 48)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self["scoretxt"], 10, 0, 0, 3, 3)

    love.graphics.setColor(colors.fg)
    if not self.beginPlay then
        love.graphics.printf("Press any key to begin", self.fontPlayAnnouce, 0, shove.getViewportHeight() / 2, shove.getViewportWidth(), "center")
    end
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(colors.fg)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", 64, shove.getViewportHeight() - 76, 480, 128, 16, 16)
    love.graphics.setColor(colors.bg)
    love.graphics.rectangle("line", 70, shove.getViewportHeight() - 70, 480 - 12, 128, 16, 16)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(colors.fg)

    love.graphics.rectangle("fill", 70, shove.getViewportHeight() - 70, math.floor(468 * (self.playerHealth / self.playerHealthMax)), 128, 16, 16)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self["heart"],
        64, shove.getViewportHeight() - 78,
        math.rad(self.angleHeart),
        self.heartScale, self.heartScale,
        self["heart"]:getWidth() * 0.5, self["heart"]:getHeight() * 0.5
    )

    if self.showRating then
        love.graphics.setColor(colors.bg)
        love.graphics.draw(self.dithbg, 0, self.posDitherY)
        love.graphics.setColor(1, 1, 1, 1)
        self.ratingScreen:draw()
    end

    if self.paused then
        love.graphics.setColor(colors.bg)
        love.graphics.draw(self.dithbg, 0, 0)
        love.graphics.setColor(1, 1, 1, 1)
        self.pauseScreen:draw()
    end

    if self.showGameOver then
        love.graphics.setColor(colors.bg)
        love.graphics.draw(self.dithalmost, 0, 0)
        love.graphics.setColor(1, 1, 1, 1)
        self.gameOverScreen:draw()
    end

    --love.graphics.print(inspect(self.rating), 30, 80)
end

function PlayState:update(elapsed)
    if not self.paused then
        Player:update(Conductor, elapsed)

        self.score = math.lerp(self.score, self.scoreTarget, 0.25)

        for _, obj in ipairs(self.objects) do
            if obj.destroy then
                -- clean up object that are marked as destroyed --
                table.remove(self.objects, _)
            end

            if obj.type ~= "judment" then
                if obj.frame < #self["particles"].quads then
                    obj.timer = obj.timer + elapsed

                    if obj.timer > 1 / 24 then
                        obj.timer = 0
                        obj.frame = obj.frame + 1

                        if obj.frame > #self["particles"].quads then
                            table.remove(self.objects, _)
                        end
                    end
                end
            end
        end

        for index, note in ipairs(self.notes) do
            if note.x < shove.getViewportWidth() and not note.wasHit then
                note:update(elapsed)
            end
        end

        Conductor.songPos = self.song:getSongPos() * 1000
        Conductor:update(elapsed)

        self.camera:zoomTo(self.camera.target.zoom)

        self.comboRender:update(elapsed)

        self.camera.target.zoom = math.lerp(self.camera.target.zoom, 1, 0.0075)
        self.angleHeart = math.wave(-7, 7, love.timer.getTime())
        --self.camera.target.y = math.lerp(self.camera.target.y, 0, 0.0075)

        self.playerHealth = math.lerp(self.playerHealth, self.playerHealthTarget, 0.058)

        if self.playerHealthTarget <= 0 and not self.gameLost then
            self.gameLost = true
            self.song:stop()
            shakeScreen(self, 2, 30, 0)
        end

        if self.gameLost and self.shakeTime <= 0 then
            self.showGameOver = true
        end

        if self.shakeTime > 0 then
            self.shakeTime = self.shakeTime - elapsed

            self.shakeX = love.math.random(-self.shakeStrength, self.shakeStrength)
            self.shakeY = love.math.random(-self.shakeStrength, self.shakeStrength)
            self.shakeAngle = love.math.random(-self.shakeAngleStrength, self.shakeAngleStrength)

            if self.shakeTime <= 0 then
                self.shakeX = 0
                self.shakeY = 0
                self.shakeAngle = 0
            end
        end

        self.camera.target.offsetX = self.camera.target.offsetX - (self.camera.target.offsetX - self.camera.target.x) * 0.03
        self.camera.target.offsetY = self.camera.target.offsetY - (self.camera.target.offsetY - self.camera.target.y) * 0.03

        self.camera.rot = math.rad(self.shakeAngle)

        self.camera.target.y = self.camera.target.y - (self.camera.target.y - shove.getViewportHeight() * 0.5) * 0.05

        self.camera.x = self.camera.target.offsetX + self.shakeX
        self.camera.y = self.camera.target.offsetY + self.shakeY

        self.heartScale = math.lerp(self.heartScale, 3, 0.065)

        updateAccuracy(self)

        if self.beginPlay and self.notesGenerated and not self.finished then
            local time = self.song.source:tell("seconds")
            if time >= self.song.source:getDuration("seconds") - 0.1 or (self.song.songEndingTime > 0 and time >= self.song.songEndingTime) then
                win(self)
            end
        end

        if self.showRating then
            self.ratingScreen:update(elapsed)
        end

        self.field.spacing = math.lerp(self.field.spacing, 144, 0.0075)
        repositionateNotes(self)
        detectHit(self)
        detectMiss(self)
    end
end

function PlayState:keypressed(k)
    if not self.beginPlay and self.notesGenerated then
        self.beginPlay = true
        --self.music:play()
        Conductor.songPos = 0
        self.song:play()
    end

    if self.showRating then
        if k == "return" then
            self.ratingScreen:transitionate()
        end
    end

    if self.gameLost and self.showGameOver and not self.paused then
        if k == "return" then
            --local data =

            self.song:rewind()
            resetNotes(self)
            self.playerHealthTarget = self.playerHealthMax
            self.scoreTarget = 0
            self.showGameOver = false
            self.gameLost = false
            self.beginPlay = false
        elseif k == "escape" then
            gamestate.switch(SongSelectionState)
        end
    end

    if self.paused and not self.showGameOver then
        if k == "return" then
            self.song:play()
            self.paused = false
        elseif k == "escape" then
            gamestate.switch(SongSelectionState)
        end
    end

    if self.beginPlay and self.notesGenerated and not self.finished and not self.showGameOver then
        if k == "escape" then
            self.song:pause()
            self.paused = true
        end
        if k == "d" then
            self.pressedKeys[1] = true
            processHit(self, 1)
        end
        if k == "k" then
            self.pressedKeys[2] = true
            processHit(self, 2)
        end
        if k == "space" then
            if not Player.isJumping then
                self.sounds["jump"]:setPitch(love.math.random(65, 106) / 100)
                self.sounds["jump"]:setVolume(0.45)
                self.sounds["jump"]:play()
            end
            Player:jump(Conductor)
        end
        if k == "f4" and FEATURE_FLAGS.developerMode then
            self.song:setTime(self.song.source:getDuration() - 4)
        end
        if k == "f6" and FEATURE_FLAGS.developerMode then
            self.playerHealthTarget = 0
        end
    end
end

function PlayState:keyreleased(k)
    for idx, value in ipairs(self.pressedKeys) do
        self.pressedKeys[idx] = false
    end
end

function PlayState:touchpressed(id, x, y, dx, dy, pressure)
    local inside, px, py = shove.screenToViewport(x, y)

    if not self.beginPlay and self.notesGenerated then
        self.beginPlay = true
        --self.music:play()
        Conductor.songPos = 0
        self.song:play()
    end

    if collision.pointRect({ x = px, y = py }, self.touchAreas["leftTouchArea"]) then
        self.pressedKeys[1] = true
        processHit(self, 1)
    end
    if collision.pointRect({ x = px, y = py }, self.touchAreas["rightTouchArea"]) then
        self.pressedKeys[2] = true
        processHit(self, 2)
    end
    if collision.pointRect({ x = px, y = py }, self.touchAreas["middleTouchArea"]) then
        if not Player.isJumping then
            self.sounds["jump"]:setPitch(love.math.random(65, 106) / 100)
            self.sounds["jump"]:setVolume(0.25)
            self.sounds["jump"]:play()
        end
        Player:jump(Conductor)
    end
end

function PlayState:touchreleased(id, x, y, dx, dy, pressure)
    for idx, value in ipairs(self.pressedKeys) do
        self.pressedKeys[idx] = false
    end
end

function PlayState:beatHit()
    self.camera.target.zoom = 1.03

    curBeat = curBeat + 1

    if curBeat % 4 == 0 then
        self.heartScale = 3.4
    end
end

function PlayState:onNoteHit(judment, lane)
    if judment == "awesome" or judment == "perfect" then
        table.insert(self.objects, {
            timer = 0,
            x = self.field.x,
            y = lane == 1 and self.field.y - self.field.spacing or self.field.y + self.field.spacing,
            frame = 1,
            scale = 1.76,
        })
    end

    if lane == 1 then
        self.camera.target.y = shove.getViewportHeight() * 0.5 - 60
    elseif lane == 2 then
        self.camera.target.y = shove.getViewportHeight() * 0.5 + 60
    end
end

function PlayState:onPlayerHit()
    shakeScreen(self, 0.25, 25, 1.7)
    self.sounds["hit"]:setPitch(love.math.random(74, 125) / 100)
    self.sounds["hit"]:play()
end

function PlayState:leave()
    self.song:stop()
end

return PlayState
