local function newImage(key, name)
    local root = "assets/images"
    local path = string.format("%s/%s", root, name)

    assetManager.loadImage(key, path)
end

local function newAudio(key, name, importMode)
    local root = "assets/sounds"
    local path = string.format("%s/%s", root, name)

    assetManager.loadAudio(key, path, importMode)
end

return function()
    newImage("cursor", "cursor.png")
    newImage("cool_disc", "cool_disc.png")
    newImage("heart", "heart.png")
    newImage("main_logo", "logo.png")
    newImage("digi_player", "digi_player.png")
    newImage("bomb", "bomb.png")
    newImage("broken_robot", "broken_robot.png")
    newImage("saw", "saw.png")
    newImage("glow", "glow.png")
    newImage("score_text", "score.png")
    newImage("judments", "judments.png")
    newImage("dance_robot", "dance_robot.png")
    newImage("numbers", "numbers.png")
    newImage("ratings", "ratings.png")
    newImage("hitlane", "hit_lane.png")
    newImage("player", "player.png")
    newImage("particles", "particles.png")
    newImage("notes", "notes.png")

    newAudio("menu_main", "music/future_base.ogg", assetManager.AudioMode.STATIC)
    newAudio("sfx_back", "back.ogg", assetManager.AudioMode.STATIC)
    newAudio("sfx_jump", "jump.ogg", assetManager.AudioMode.STATIC)
    newAudio("sfx_song_select", "song_select.ogg", assetManager.AudioMode.STATIC)
    newAudio("sfx_hit", "hit.ogg", assetManager.AudioMode.STATIC)
end
