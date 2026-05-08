ConvertState = {}

function ConvertState:enter()

end

function ConvertState:draw()

end

function ConvertState:update(elapsed)

end

function ConvertState:filedropped(file)
    local chartData = json.decode(file:read())

    local base = {
        meta = {
            bpm = 128,
            scrollSpeed = 1.68,
            songStartOffset = 0,
            song = "iloveyou",
            artist = "TreePalm",
            songEnding = 95
        },
        notes = {}
    }

    for idx, note in ipairs(chartData.groups["Notes"]) do
        table.insert(base.notes, {
            lane = note.row,
            time = note.time * 1000
        })
    end

    local f = love.filesystem.newFile("songConverted.json", "w")
    f:write(json.encode(base))
    f:close()
    file:close()
end

return ConvertState
