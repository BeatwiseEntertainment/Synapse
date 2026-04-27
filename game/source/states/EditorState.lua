EditorState = {}

local Song = require 'source.game.Song'
local Note = require 'source.game.Note'
local Conductor = require 'source.game.Conductor'

EditorState.song = nil

local function renderChecker(size, x, y, color1, color2)
    local flip = false

    for i = 0, (shove.getViewportWidth() + 64) / size, 1 do
        love.graphics.setColor(flip and color2 or color1)
        love.graphics.rectangle("fill", x + i * size, y, size, size)
        love.graphics.setColor(1, 1, 1, 1)
        flip = not flip
    end
end

local function repositionateNotes(self)
    for index, note in ipairs(self.notes) do

    end
end

function EditorState:enter()
    loveView.unloadView()

    loveframes.SetActiveSkin("Dark crimson")

    self.canAddNote = false

    self.notes = {}

    table.insert(self.notes, Note:new(2.78, 1, self.notes[1]))

    self.song = Song:new() --blank song --

    loveView.registerLoveframesEvents()
    loveView.loadView("src/Modules/Game/Views/Editor.lua")

    --print(inspect(love.system))
end

function EditorState:draw()
    renderChecker(32, 0, PlayState.field.y - PlayState.field.spacing, { 0.75, 0.75, 0.75 }, { 0.45, 0.45, 0.45 })
    renderChecker(32, 0, PlayState.field.y + PlayState.field.spacing, { 0.75, 0.75, 0.75 }, { 0.45, 0.45, 0.45 })

    -- where the player hit the note --
    love.graphics.setBlendMode("multiply", "premultiplied")
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", 0, 0, PlayState.field.x, shove.getViewportHeight())
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha", "alphamultiply")

    love.graphics.line(PlayState.field.x, 0, PlayState.field.x, shove.getViewportHeight())

    for index, note in ipairs(self.notes) do
        if note.mustHit then
            love.graphics.setColor(0, 1, 0, 1)
        end
        love.graphics.circle("fill", self.song:timeToX(note.time, self.song:getTime(), PlayState.field.x), PlayState.field.y, 48)
        love.graphics.setColor(1, 1, 1, 1)
    end

    loveView.draw()
end

function EditorState:update(elapsed)
    loveView.update(elapsed)

    Conductor.songPos = self.song:getTime()
    Conductor:update(elapsed)

    local renderWindow = 4000

    for index, note in ipairs(self.notes) do
        if note.mustHit then
            local time = note.time - Conductor.offset

            note.canBeHit =
                time >= -(Conductor.safeFramesOffset * 2)
                and time <= (Conductor.safeFramesOffset * 0.75)
        end

        local diff = note.time - Conductor.songPos
        note.x = PlayState.field.x + diff * self.song.scrollSpeed
    end
end

function EditorState:exportSong()
    love.filesystem.createDirectory("export")

    local file = love.filesystem.newFile("export/" .. Song.song:gsub("%.[^.]+$", "")) -- remove the extension --
    file:write(Song:encode())
    file:close()

    return "ok"
end

function EditorState:mousepressed(x, y, button)
    if not self.canAddNote then return end
end

function EditorState:leave()
    loveView.unloadView()
end

return EditorState
