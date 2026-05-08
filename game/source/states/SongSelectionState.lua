SongSelectionState = {}

local beat = 0
local Conductor = require 'source.game.Conductor'
local Event = require 'source.game.Event'
local Shake = require 'source.game.Shake'

local colors = {
    fg = { lume.color("#ffb84a") },
    bg = { lume.color("#0e0421") }
}

local function reset(self)
    self.previewSongs.vol = 0
    beat = 0

    if self.songList[self.currentSelected] then
        self.previewSongs.musics[self.songList[self.currentSelected].audioID]:stop()
    end
end

local function updateSelectionSong(self)
    if self.currentSelected > #self.songList then
        self.currentSelected = 1
    end
    if self.currentSelected < 1 then
        self.currentSelected = #self.songList
    end

    local songData = self.songList[self.currentSelected]

    if self.songList[self.currentSelected] then
        self.previewSongs.musics[songData.audioID]:stop()
        self.previewSongs.musics[songData.audioID]:seek(songData.startPreview)
        self.previewSongs.musics[songData.audioID]:play()
        flux.to(self.previewSongs, 1.6, { vol = 1 }):ease("linear")
    end
end

local function newMusic(title, artist, difficulty, bpm, startPreview, previewSeconds, audioID)
    return {
        title = title,
        artist = artist,
        difficulty = difficulty,
        bpm = bpm,
        startPreview = startPreview,
        secondsPreview = previewSeconds,
        audioID = audioID
    }
end

local function playSong(self)
    local currentSelectedSong = self.songList[self.currentSelected]
    if self.inTransition then return end

    self.inTransition = true
    flux.to(self.previewSongs, 0.5, { vol = 0 })
        :ease("linear")
        :oncomplete(function()
            --self.sounds[self.songs[self.curSelected].name]:stop()
            self.previewSongs.musics[currentSelectedSong.audioID]:stop()
        end)

    masterMixer:setChannelPitch("sfx", math.random(74, 125) / 100)
    masterMixer:playChannel("sfx", "sfx_select")

    flux.to(self, 2, { transitionScreenY = -(128 + shove.getViewportHeight()) })
        :ease("sineout")
        :oncomplete(function()
            PlayState.songName = string.lower(currentSelectedSong.title):gsub(" ", "_")
            gamestate.switch(PlayState)
        end)
        :delay(0.25)
end

function SongSelectionState:enter()
    local path = "assets/images/"

    love.graphics.setBackgroundColor(colors.bg)

    self.inTransition = false

    self.currentPlayingSong = nil
    self.currentSelected = 1

    self.capeObject = {
        scale = 0,
        angle = 0,
        maxScale = 2.76,
        minScale = 2.25
    }

    self.transitionScreenY = shove.getViewportWidth()

    self.capeObject.scale = self.capeObject.minScale

    self.camera = camera(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)

    Conductor.bpm = 91
    Conductor.songPos = 0

    self.songList = {
        newMusic("Tutorial", "NimbusEclipse", 2, 100, 10, 20, "msc_tutorial"),
        newMusic("Cry", "Sacha Ende", 4, 100, 40, 20, "msc_cry"),
        newMusic("I love you", "TreePalm", 5, 128, 63, 20, "msc_i_love_you"),
    }

    local img = assetManager.getImage("buttonSelect")
    self["buttonSelect"] = assetManager.getImage("buttonSelect")

    self["cape"] = assetManager.getImage("cape")
    self["cool_disc"] = assetManager.getImage("cool_disc")
    self["gradient"] = love.graphics.newGradient("vertical", {
        { lume.color("rgba(255, 255, 255, 0)") },
        { lume.color("rgba(255, 255, 255, 255)") },
    })
    self["robozito"] = {}
    self["robozito"].img = assetManager.getImage("dance_robot")
    self["robozito"].quads = love.graphics.getQuads(self["robozito"].img, love.filesystem.read(path .. "dance_robot.json"), "array")

    self["diff"] = {}
    self["diff"].img = assetManager.getImage("difficulty_counter")
    self["diff"].quads = love.graphics.getQuads(self["diff"].img, love.filesystem.read(path .. "difficulty_counter.json"), "hash")

    self["cape"] = assetManager.getImage("cape")

    self.targetZoom = 1

    self.fontTitle = assetManager.getFont("monogram", 90)
    self.fontSong = assetManager.getFont("monogram", 48)
    self.fontSelect = assetManager.getFont("monogram", 45)
    self.leaderboardFont = assetManager.getFont("monogram", 32)

    --self.frame = patchy.load(assetManager.getImage("frame"))
    self.frame = patchy.load(assetManager.getImage("frame"), 32, 32)

    masterMixer:addSource("sfx_select", assetManager.getAudio("sfx_song_select"))

    local buttonScale = 1.2
    self.buttons = {
        ["leftButton"] = {
            img = self["buttonSelect"],
            x = 0,
            y = 0,
            w = 0,
            h = 0,
            scale = buttonScale,
            flipped = false,
        },
        ["rightButton"] = {
            img = self["buttonSelect"],
            x = 0,
            y = 0,
            w = 0,
            h = 0,
            scale = buttonScale,
            flipped = true
        },
        ["playButton"] = {
            img = nil,
            x = 0,
            y = 0,
            w = 0,
            h = 0,
            scale = 1,
            flipped = false
        },
    }

    self.previewSongs = {
        vol = 1,
        musics = {}
    }

    self.previewSongs.musics["msc_cry"] = assetManager.getAudio("msc_cry")
    self.previewSongs.musics["msc_i_love_you"] = assetManager.getAudio("msc_i_love_you")
    self.previewSongs.musics["msc_tutorial"] = assetManager.getAudio("msc_tutorial")

    self.buttons["leftButton"].w = img:getWidth() * buttonScale
    self.buttons["leftButton"].h = img:getHeight() * buttonScale

    self.buttons["rightButton"].w = img:getWidth() * buttonScale
    self.buttons["rightButton"].h = img:getHeight() * buttonScale

    self.transition = {

    }

    -- bind conductor hit to a scene event --
    Event.hook(Conductor, { "beatHit" })
    Conductor.beatHit = function()
        if SongSelectionState.beatHit then
            SongSelectionState.beatHit(SongSelectionState)
        end
    end


    --self.previewSongs.musics[self.songList[self.currentSelected].audioID]:setVolume(1)
    --self.previewSongs.musics[self.songList[self.currentSelected].audioID]:seek(self.songList[self.currentSelected].startPreview)
    --self.previewSongs.musics[self.songList[self.currentSelected].audioID]:play()

    print(self.songList[self.currentSelected].audioID)

    --reset(self)
    updateSelectionSong(self)

    flux.to(self.previewSongs, 1.6, { vol = 1 }):ease("linear")
end

function SongSelectionState:draw()
    --love.graphics.draw(self.gradient, 32, 32, 0, 128, 128)
    self.camera:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
    local songData = self.songList[self.currentSelected]

    love.graphics.draw(
        self["robozito"].img,
        self["robozito"].quads[self.robotFrame],
        64, shove.getViewportHeight() - 256, 0, 3.5, 3.5
    )

    local frameWidth, frameHeight = 1000, 300
    local px = shove.getViewportWidth() * 0.5 - frameWidth * 0.5
    local py = (shove.getViewportHeight() * 0.5 - frameHeight * 0.5) - 120
    self.buttons["playButton"].x = px
    self.buttons["playButton"].y = py
    self.buttons["playButton"].w = frameWidth
    self.buttons["playButton"].h = frameHeight
    patchy.draw(self.frame, px, py, frameWidth, frameHeight, 1.5, 1.5)

    self.buttons["leftButton"].x = 16
    self.buttons["leftButton"].y = py + 48

    self.buttons["rightButton"].x = (frameWidth + self.buttons["rightButton"].w) + 32
    self.buttons["rightButton"].y = py + 48

    for key, button in pairs(self.buttons) do
        --love.graphics.draw(button.img, button.x + button.w * 0.5, button.y, 0, button.scale, button.scale, button.w * 0.5)
        if button.img then
            love.graphics.draw(button.img, button.x + button.w * 0.5, button.y, 0, button.flipped and -button.scale or button.scale, button.scale, button.img:getWidth() * 0.5)
        end
        --love.graphics.rectangle("line", button.x, button.y, button.w, button.h)
    end

    love.graphics.draw(
        self["cape"], px + 150, (py + frameHeight * 0.5) - 32,
        math.rad(self.capeObject.angle), self.capeObject.scale, self.capeObject.scale,
        self["cape"]:getWidth() * 0.5, self["cape"]:getHeight() * 0.5
    )

    -- render difficulty --
    for i = 1, 10, 1 do
        local startX, startY = px + 300, (py + frameHeight) - 78

        love.graphics.draw(self["diff"].img, self["diff"].quads[i > songData.difficulty and "empty" or "full"], startX + 48 * i, startY, 0, 1.5, 1.5)
    end

    -- render text --
    love.graphics.setColor(colors.fg)
    love.graphics.printf(
        songData.title, self.fontTitle,
        px + frameWidth * 0.4, py + (frameHeight * 0.5 - self.fontTitle:getHeight() * 0.5) * 0.5,
        frameWidth * 0.4, "center"
    )
    love.graphics.printf(
        songData.artist, self.fontSong,
        px + frameWidth * 0.4, py + 138,
        frameWidth * 0.4, "center"
    )
    love.graphics.setColor(1, 1, 1, 1)
    self.camera:detach()

    love.graphics.setColor(colors.bg)
    love.graphics.draw(self["gradient"], 0, self.transitionScreenY, 0, shove.getViewportWidth(), 128)

    love.graphics.rectangle("fill", 0, 128 + self.transitionScreenY, shove.getViewportWidth(), shove.getViewportHeight() * 2)
    love.graphics.setColor(1, 1, 1, 1)
end

function SongSelectionState:update(elapsed)
    local currentSelectedSong = self.songList[self.currentSelected]

    if self.songList[self.currentSelected] then
        Conductor.bpm = currentSelectedSong.bpm
        Conductor.songPos = self.previewSongs.musics[currentSelectedSong.audioID]:tell() * 1000
        Conductor.update()


        if self.previewSongs.musics[currentSelectedSong.audioID]:tell() >= currentSelectedSong.secondsPreview + currentSelectedSong.startPreview and not self.inTransition then
            self.inTransition = true

            flux.to(self.previewSongs, 1.6, { vol = 0 })
                :oncomplete(function()
                    self.previewSongs.musics[currentSelectedSong.audioID]:stop()
                    self.previewSongs.musics[currentSelectedSong.audioID]:seek(currentSelectedSong.startPreview)

                    flux.to(self.previewSongs, 1.6, { vol = 1 })
                        :ease("linear")
                        :onstart(function()
                            self.previewSongs.musics[currentSelectedSong.audioID]:play()
                            self.inTransition = false
                        end)
                        :delay(1)
                end)
        end

        self.previewSongs.musics[currentSelectedSong.audioID]:setVolume(self.previewSongs.vol)
    end
    local beatProgress = (Conductor.songPos % Conductor.crochet) / Conductor.crochet
    self.robotFrame = math.floor(beatProgress * #self["robozito"].quads) + 1

    self.capeObject.scale = math.lerp(self.capeObject.scale, self.capeObject.minScale, 0.057)
    self.capeObject.angle = math.lerp(self.capeObject.angle, 0, 0.065)

    self.targetZoom = math.lerp(self.targetZoom, 1, 0.067)
    self.camera:zoomTo(self.targetZoom)
end

function SongSelectionState:touchpressed(id, x, y, dx, dy, pressure)
    local inside, px, py = shove.screenToViewport(x, y)

    for buttonID, area in pairs(self.buttons) do
        if collision.pointRect({ x = px, y = py }, area) and buttonID == "leftButton" then
            reset(self)
            self.currentSelected = self.currentSelected - 1
            updateSelectionSong(self)
        end

        if collision.pointRect({ x = px, y = py }, area) and buttonID == "rightButton" then
            reset(self)
            self.currentSelected = self.currentSelected + 1
            updateSelectionSong(self)
        end

        if collision.pointRect({ x = px, y = py }, area) and buttonID == "playButton" then
            playSong(self)
        end
    end
end

function SongSelectionState:mousepressed(x, y, button)
    local inside, px, py = shove.mouseToViewport()

    for buttonID, area in pairs(self.buttons) do
        if collision.pointRect({ x = px, y = py }, area) and buttonID == "leftButton" then
            reset(self)
            self.currentSelected = self.currentSelected - 1
            updateSelectionSong(self)
        end

        if collision.pointRect({ x = px, y = py }, area) and buttonID == "rightButton" then
            reset(self)
            self.currentSelected = self.currentSelected + 1
            updateSelectionSong(self)
        end

        if collision.pointRect({ x = px, y = py }, area) and buttonID == "playButton" then
            playSong(self)
        end
    end
end

function SongSelectionState:keypressed(k)
    local currentSelectedSong = self.songList[self.currentSelected]

    if k == "left" then
        reset(self)
        self.currentSelected = self.currentSelected - 1
        updateSelectionSong(self)
    end

    if k == "right" then
        reset(self)
        self.currentSelected = self.currentSelected + 1
        updateSelectionSong(self)
    end

    if k == "return" then
        playSong(self)
    end
end

-- music releated event --
function SongSelectionState:beatHit()
    beat = beat + 1

    if beat % 2 == 0 then
        self.capeObject.angle = lume.randomchoice({ -10, -7 })
        self.targetZoom = 1.032
    else
        self.capeObject.angle = lume.randomchoice({ 10, 7 })
    end

    self.capeObject.scale = self.capeObject.maxScale
end

return SongSelectionState
