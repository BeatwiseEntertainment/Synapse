return function()
    local new = loveframes.Create
    local settings = {
        font = fontcache.getFont("vcr", 23),
        fontbtn = fontcache.getFont("vcr", 19),
    }
    local padding = 8

    local panel = new("panel")
    panel:SetSize(340, 480)
    panel:SetX(shove.getViewportWidth() - panel:GetWidth())
    panel:SetY(64)

    local bpmY = 16
    local textBPM = new("text")
    textBPM:SetParent(panel)
    textBPM:SetDefaultColor(1, 1, 1, 1)
    textBPM:SetFont(settings.font)
    textBPM:SetText("BPM:")
    textBPM:SetPos(padding, bpmY)

    local bpmInput = new("numberbox")
    bpmInput:SetParent(panel)
    bpmInput:SetSize(64, textBPM:GetHeight())
    bpmInput:SetX(textBPM:GetWidth() + 16)
    bpmInput:SetY(bpmY)
    bpmInput:SetMinMax(1, 1000)
    bpmInput:SetValue(EditorState.song.bpm)
    bpmInput.OnValueChanged = function(obj, val)
        EditorState.song.bpm = val
    end

    local scrollY = 64
    local textScroll = new("text")
    textScroll:SetParent(panel)
    textScroll:SetDefaultColor(1, 1, 1, 1)
    textScroll:SetFont(settings.font)
    textScroll:SetText("Scroll Speed: %s")
    textScroll:SetPos(padding, scrollY)
    textScroll.Update = function(obj, elapsed)
        obj:SetText(string.format("Scroll Speed: %.2f", EditorState.song.scrollSpeed))
    end

    local buttonDecScroll = new("button")
    buttonDecScroll:SetParent(panel)
    buttonDecScroll:SetSize(32, 32)
    buttonDecScroll:SetText("-")
    buttonDecScroll:SetFont(settings.font)
    local btnX = (panel:GetWidth() - buttonDecScroll:GetWidth()) - padding
    buttonDecScroll:SetPos(btnX, scrollY - 8)
    buttonDecScroll.OnClick = function(obj)
        EditorState.song.scrollSpeed = EditorState.song.scrollSpeed - 0.01
    end

    local buttonAddScroll = new("button")
    buttonAddScroll:SetParent(panel)
    buttonAddScroll:SetSize(32, 32)
    buttonAddScroll:SetText("+")
    buttonAddScroll:SetFont(settings.font)
    local btnX = (panel:GetWidth() - (buttonAddScroll:GetWidth() + buttonDecScroll:GetWidth())) - padding * 2
    buttonAddScroll:SetPos(btnX, scrollY - 8)
    buttonAddScroll.OnClick = function(obj)
        EditorState.song.scrollSpeed = EditorState.song.scrollSpeed + 0.01
    end

    local audio = 114
    local textAudioName = new("text")
    textAudioName:SetParent(panel)
    textAudioName:SetDefaultColor(1, 1, 1, 1)
    textAudioName:SetFont(settings.font)
    textAudioName:SetText("Audio %")
    textAudioName:SetPos(padding, audio)
    textAudioName.Update = function(obj, elapsed)
        obj:SetText(string.format("Audio: %s", EditorState.song.songLoaded and "Loaded" or "Not loaded"))
    end

    local audioInput = 158
    local songName = new("textinput")
    songName:SetParent(panel)
    songName:SetSize(128, 32)
    songName:SetPos(padding, audioInput)

    local btnLoadSong = new("button")
    btnLoadSong:SetParent(panel)
    btnLoadSong:SetText("Reload song")
    btnLoadSong:SetFont(settings.fontbtn)
    btnLoadSong:SetPos(padding + songName:GetWidth() + 6, audioInput)
    btnLoadSong:SetSize(158, 32)
    btnLoadSong.OnClick = function(obj)
        EditorState.song.song = songName:GetValue()
        EditorState.song:loadAudio()
    end

    local artist = 214
    local textArtist = new("text")
    textArtist:SetParent(panel)
    textArtist:SetDefaultColor(1, 1, 1, 1)
    textArtist:SetText("artist")
    textArtist:SetFont(settings.font)
    textArtist:SetPos(padding, artist)

    local artistInput = new("textinput")
    artistInput:SetParent(panel)
    artistInput:SetSize(128, 32)
    artistInput:SetPos(padding + textArtist:GetWidth() + 8, artist)

    local buttonSave = new("button")
    buttonSave:SetParent(panel)
    buttonSave:SetText("Save song")
    buttonSave:SetFont(settings.fontbtn)
    buttonSave:SetSize(158, 32)
    buttonSave:SetPos(padding, panel:GetHeight() - (buttonSave:GetHeight() + 8))
    buttonSave.OnClick = function()
        EditorState:exportSong()
    end
end
