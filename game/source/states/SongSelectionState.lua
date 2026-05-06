SongSelectionState = {}

local beat = 0
local Conductor = require 'source.game.Conductor'
local Event = require 'source.game.Event'
local Shake = require 'source.game.Shake'

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

function SongSelectionState:enter()
    local path = "assets/images/"

    self.songList = {
        newMusic("Tutorial", "NimbusEclipse", 2, 100, 10, 20, "msc_tutorial"),
        newMusic("Cry", "Sacha Ende", 4, 100, 10, 20, "msc_cry"),
        newMusic("I love you La La La", "TreePalm", 4, 100, 10, 20, "msc_iloveyou"),
    }

    self["cape"] = assetManager.getImage("cape")
    self["cool_disc"] = assetManager.getImage("cool_disc")
    self["gradient"] = love.graphics.newGradient("vertical", {
        { lume.color("rgba(255, 255, 255, 0)") },
        { lume.color("rgba(255, 255, 255, 255)") },
    })
    self["robozito"] = {}
    self["robozito"].img = assetManager.getImage("dance_robot")
    self["robozito"].quads = love.graphics.getQuads(self["robozito"].img, love.filesystem.read(path .. "dance_robot.json"), "array")

    self.transition = {

    }

    -- bind conductor hit to a scene event --
    Event.hook(Conductor, { "beatHit" })
    Conductor.beatHit = function()
        if SongSelectionState.beatHit then
            SongSelectionState.beatHit(SongSelectionState)
        end
    end
end

function SongSelectionState:draw()
    love.graphics.draw(self.gradient, 32, 32, 0, 128, 128)
end

function SongSelectionState:update(elapsed)
    Conductor.update()
end

-- music releated event --
function SongSelectionState:beatHit()

end

return SongSelectionState
