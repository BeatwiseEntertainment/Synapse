SongSelectionState = {}

local beat = 0
local Conductor = require 'source.game.Conductor'
local Event = require 'source.game.Event'
local Shake = require 'source.game.Shake'

local colors = {
    fg = { lume.color("#ffb84a") },
    bg = { lume.color("#0e0421") }
}
function SongSelectionState:enter()
    local path = "assets/images/game/"

    love.graphics.setDefaultFilter("nearest", "nearest")

    self["bg_deco"] = love.graphics.newImage(path .. "bg_deco.png")
    self["cape"] = love.graphics.newImage(path .. "cape.png")
    self["cool_disc"] = love.graphics.newImage(path .. "cool_disc.png")
    self["gradient"] = love.graphics.newImage(path .. "gradient_down.png")
    self["robozito"] = {}
    local img = love.graphics.newImage(path .. "robozito.png")
    self["robozito"].img = assetManager.getImage("dance_robot")
    self["robozito"].quads = love.graphics.getQuads(img, path .. "robozito.json", "array")

    self.sounds = {}

    self.vol = 0
    self.sounds["select"] = assetManager.getAudio("sfx_song_select")
    self.sounds["cry"] = assetManager.getAudio("sfx_cry")
    self.sounds["nulctrl"] = assetManager.getAudio("sfx_nulctrl")
    self.sounds["tutorial"] = assetManager.getAudio("sfx_tutorial")

    love.graphics.setBackgroundColor(colors.bg)

    self.fontTitle = fontcache.getFont("monogram", 80)
    self.fontSong = fontcache.getFont("monogram", 55)
    self.fontSelect = fontcache.getFont("monogram", 45)

    Event.hook(Conductor, { "beatHit" })
    Conductor.beatHit = function()
        if SongSelectionState.beatHit then
            SongSelectionState.beatHit(SongSelectionState)
        end
    end

    Conductor.bpm = 91
    Conductor.songPos = 0

    self.curSelected = 1
    self.inTransition = false

    self.capeX = shove.getViewportWidth() - 170
    self.capeY = shove.getViewportHeight() * 0.5
    self.capeScale = 4
    self.discAngle = 0
    self.discBump = 3

    self.transitionScreenY = shove.getViewportWidth()
    self.robotTimer = 0
    self.robotFrame = 1

    self.songs = {
        {
            name = "tutorial",
            artist = "NimbusEclipse",
            difficulty = 1,
            bpm = 100,
            startPreview = 10,
            secondsPreview = 20,
        },
        {
            name = "cry",
            artist = "Sacha Ende",
            difficulty = 4,
            bpm = 100,
            startPreview = 40,
            secondsPreview = 20,
        },
        {
            name = "nulctrl",
            artist = "SilentRoom",
            difficulty = 4,
            bpm = 100,
            startPreview = 36,
            secondsPreview = 20,
        },
    }

    self.sounds[self.songs[self.curSelected].name]:seek(self.songs[self.curSelected].startPreview)
    self.sounds[self.songs[self.curSelected].name]:setVolume(self.vol)
    self.sounds[self.songs[self.curSelected].name]:play()

    flux.to(self, 1.6, { vol = 1 }):ease("linear")

    self.name = {
        x = shove.getViewportWidth() + 100,
        y = shove.getViewportHeight() + 150,
        alpha = 0
    }

    self.nametween = flux.group()

    self.nametween:to(self.name, 1.5, { alpha = 1, x = self.name.x - self.fontSong:getWidth(self.songs[self.curSelected].name) + 32 }):ease("backout")
end

local function line(x1, y1, x2, y2)
    love.graphics.rectangle("fill", x1, y1, x2, 3)
end

function SongSelectionState:draw()
    --Shake:start()
    love.graphics.setColor(colors.fg)
    love.graphics.printf("Song selection", self.fontTitle, 0, 32, shove.getViewportWidth(), "center")


    love.graphics.setLineWidth(3)
    love.graphics.line(0, 135, shove.getViewportWidth(), 135)
    love.graphics.line(256, 135, 256, shove.getViewportHeight())
    love.graphics.line(shove.getViewportWidth() - 380, 135, shove.getViewportWidth() - 380, shove.getViewportHeight())
    love.graphics.line(256, 240, (shove.getViewportWidth() - 380), 240)

    love.graphics.printf("#", self.fontSong, 269, 243, (shove.getViewportWidth() - 380) - 256, "left")
    love.graphics.printf("Score", self.fontSong, 256, 243, (shove.getViewportWidth() - 380) - 256, "center")

    love.graphics.line(256, 290, (shove.getViewportWidth() - 380), 290)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(
        self["robozito"].img,
        self["robozito"].quads[self.robotFrame],
        shove.getViewportWidth() * 0.5 - 400, 16, 0, 3.5, 3.5
    )

    love.graphics.draw(self["cape"],
        self.capeX, self.capeY, math.rad(Shake.rotation),
        self.capeScale, self.capeScale,
        self["cape"]:getWidth() * 0.5,
        self["cape"]:getHeight() * 0.5
    )

    love.graphics.setColor(colors.fg)
    love.graphics.printf(
        self.songs[self.curSelected].name,
        self.fontSong, shove.getViewportWidth() - 380,
        shove.getViewportHeight() * 0.5 + 170,
        shove.getViewportWidth() - (shove.getViewportWidth() - 380), "center"
    )
    love.graphics.printf(
        string.format("By: %s\nBPM: %s", self.songs[self.curSelected].artist, self.songs[self.curSelected].bpm),
        self.fontSelect, shove.getViewportWidth() - 380,
        (shove.getViewportHeight() * 0.5 + 170) + self.fontSong:getHeight() + 8,
        shove.getViewportWidth() - (shove.getViewportWidth() - 380), "center"
    )

    love.graphics.printf("Leaderboards", self.fontSong, 256, 160, (shove.getViewportWidth() - 380) - 256, "center")

    local startY = shove.getViewportHeight() / 3 - 28
    if gameSave.save.user.leaderboard[self.songs[self.curSelected].name] then
        if #gameSave.save.user.leaderboard[self.songs[self.curSelected].name] > 0 then
            for idx, entry in ipairs(gameSave.save.user.leaderboard[self.songs[self.curSelected].name]) do
                love.graphics.setColor(colors.fg)
                local posY = startY + (self.fontSong:getHeight() + 16) * idx
                local posYLine = posY + (self.fontSong:getHeight() + 16)

                love.graphics.printf(idx .. "#", self.fontSong, 269, posY, (shove.getViewportWidth() - 380) - 256, "left")
                love.graphics.printf(entry, self.fontSong, 256, posY, (shove.getViewportWidth() - 380) - 256, "center")
                love.graphics.setLineWidth(3)
                love.graphics.line(256, posYLine, (shove.getViewportWidth() - 380), posYLine)
                love.graphics.setLineWidth(1)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    else
        love.graphics.printf("No entries yet...", self.fontSong, 256, shove.getViewportHeight() * 0.5, (shove.getViewportWidth() - 380) - 256, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)
    local spacing = 24
    for index, song in ipairs(self.songs) do
        if self.curSelected == index then
            love.graphics.setColor(colors.fg)
            love.graphics.rectangle("fill",
                0, 96 + ((self.fontSelect:getHeight() + 8) + spacing) * index, 256,
                self.fontSelect:getHeight() + 16
            )
            love.graphics.setColor(colors.bg)
        else
            love.graphics.setColor(colors.fg)
        end
        love.graphics.printf(song.name, self.fontSelect, 0, 96 + ((self.fontSelect:getHeight() + 8) + spacing) * index, 256, "center")
    end
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(self["gradient"], 0, self.transitionScreenY, 0, 1, 1)
    love.graphics.setColor(colors.bg)
    love.graphics.rectangle("fill", 0, self["gradient"]:getHeight() + self.transitionScreenY, shove.getViewportWidth(), shove.getViewportHeight() * 2)
    love.graphics.setColor(1, 1, 1, 1)
end

function SongSelectionState:update(elapsed)
    if self.songs[self.curSelected] then
        Conductor.bpm = self.songs[self.curSelected].bpm
        Conductor.songPos = self.sounds[self.songs[self.curSelected].name]:tell() * 1000
        Conductor:update(elapsed)

        self.discAngle = self.discAngle + 20 * elapsed

        if self.sounds[self.songs[self.curSelected].name]:tell() >= self.songs[self.curSelected].secondsPreview + self.songs[self.curSelected].startPreview and not self.inTransition then
            --self.sounds[self.songs[self.curSelected].name]:tell()
            self.inTransition = true
            flux.to(self, 1.6, { vol = 0 })
                :oncomplete(function()
                    self.sounds[self.songs[self.curSelected].name]:stop()
                    self.sounds[self.songs[self.curSelected].name]:seek(self.songs[self.curSelected].startPreview)

                    flux.to(self, 1.6, { vol = 1 })
                        :ease("linear")
                        :onstart(function()
                            self.sounds[self.songs[self.curSelected].name]:play()
                            self.inTransition = false
                        end)
                        :delay(1)
                end)
        end

        self.sounds[self.songs[self.curSelected].name]:setVolume(self.vol)
    end

    local beatProgress = (Conductor.songPos % Conductor.crochet) / Conductor.crochet

    self.robotFrame = math.floor(beatProgress * #self["robozito"].quads) + 1

    self.capeScale = math.lerp(self.capeScale, 4, 0.057)


    Shake:update(elapsed)
end

function SongSelectionState:beatHit()
    beat = beat + 1
    --Shake:rotate(lume.randomchoice({ -7, 7, -10, 10, -3, 3 }))

    if beat % 2 == 0 then
        Shake:rotate(lume.randomchoice({ -10, -7 }))
    else
        Shake:rotate(lume.randomchoice({ 10, 3 }))
    end

    self.capeScale = 4.25
end

local function reset(self)
    self.vol = 0

    if self.songs[self.curSelected] then
        self.sounds[self.songs[self.curSelected].name]:stop()
    end
end

local function updateSelectionSong(self)
    if self.curSelected > #self.songs then
        self.curSelected = 1
    end
    if self.curSelected < 1 then
        self.curSelected = #self.songs
    end

    if self.songs[self.curSelected] then
        self.sounds[self.songs[self.curSelected].name]:stop()
        self.sounds[self.songs[self.curSelected].name]:seek(self.songs[self.curSelected].startPreview)
        self.sounds[self.songs[self.curSelected].name]:play()
        flux.to(self, 1.6, { vol = 1 }):ease("linear")
    end
end

function SongSelectionState:keypressed(k)
    if k == "down" then
        reset(self)
        self.curSelected = self.curSelected + 1
        updateSelectionSong(self)
    end
    if k == "up" then
        reset(self)
        self.curSelected = self.curSelected - 1
        updateSelectionSong(self)
    end

    if k == "return" then
        -- the shitty --
        if self.inTransition then return end

        self.inTransition = true

        flux.to(self, 0.5, { vol = 0 })
            :ease("linear")
            :oncomplete(function()
                self.sounds[self.songs[self.curSelected].name]:stop()
            end)

        self.sounds["select"]:setPitch(math.random(74, 125) / 100)
        self.sounds["select"]:play()

        flux.to(self, 2, { transitionScreenY = -(self["gradient"]:getHeight() + shove.getViewportHeight()) })
            :ease("sineinout")
            :oncomplete(function()
                PlayState.songName = self.songs[self.curSelected].name:gsub(" ", "_")
                gamestate.switch(PlayState)
            end)
            :delay(0.25)
    end
end

function SongSelectionState:leave()
    for key, value in pairs(self.sounds) do
        value:stop()
    end
    love.graphics.release(self)
end

return SongSelectionState
