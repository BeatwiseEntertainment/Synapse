local Song = class:extend("Song")

function Song:__construct()
    self.bpm = 100
    self.scrollSpeed = 1.7
    self.songStartOffset = 0
    self.song = ""
    self.artist = ""
    self.source = nil
    self.songLoaded = false
    self.notes = {}
end

function Song:encode()
    local notes = {}
    for i, note in ipairs(self.notes) do
        notes[i] = {
            lane = note.lane,
            type = note.type,
            time = note.time
        }
    end


    return json.encode({
        bpm = self.bpm,
        scrollSpeed = self.scrollSpeed,
        songStartOffset = self.songStartOffset,
        song = self.song,
        artist = self.artist,
        notes = notes,
    })
end

function Song:loadAudio(audioSource)
    self.source = audioSource
    self.songLoaded = true
end

function Song:play()
    if self.source == nil then return end
    self.source:play()
end

function Song:pause()
    if self.source == nil then return end
    self.source:pause()
end

function Song:rewind()
    if self.source == nil then return end
    self.source:seek(0)
end

function Song:stop()
    if self.source == nil then return end
    self.source:stop()
end

function Song:release()
    if not self.source then return end
    self.source:release()
    self.songLoaded = false
end

function Song:getTime()
    if self.source == nil and not self.songLoaded then return 0 end

    return self.source:tell("seconds") --return in milisseconds
end

function Song:getSongPos()
    return self:getTime() + self.songStartOffset
end

function Song:setTime(timeSec)
    if self.source == nil and not self.source:isPlaying() then return end

    return self.source:seek(timeSec, "seconds")
end

function Song:loadFromJson(path)
    local p = "assets/data/"
    --if love.filesystem.getInfo(p .. path) == nil then return end
    --print(p .. path)

    local data = json.decode(love.filesystem.read(p .. path .. ".json"))
    self.bpm = data.meta.bpm
    self.scrollSpeed = data.meta.scrollSpeed
    self.songStartOffset = data.meta.songStartOffset
    self.notes = data.notes
    self.song = data.meta.song
    self.artist = data.meta.artist
    self.songEndingTime = data.meta.songEnding

    --for _, note in ipairs(self.notes) do
    --    note.time = note.time * 1000
    --end
end

return Song
