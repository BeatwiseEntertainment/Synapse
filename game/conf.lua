function love.conf(w)
    --% Window %--
    w.window.width    = 1280
    w.window.height   = 768
    w.window.icon     = "icon.png"
    w.window.title    = love.filesystem.isFused() and "Synapse" or "[DEBUG] Synapse"
    w.window.depth    = love._version_major >= 12 and true or 16

    --% Debug %--
    w.console         = not love.filesystem.isFused()

    --% Storage %--
    w.externalstorage = true
    w.identity        = "com.beatwiseentertainment.synapse"
end
