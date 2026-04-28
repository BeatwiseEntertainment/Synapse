PausedSubstate = {}

function PausedSubstate:load()
    self.fontPausedTitle = assetManager.getFont("monogram", 80)
    self.fontPaused = assetManager.getFont("monogram", 55)
    self.fontSelect = assetManager.getFont("monogram", 45)
end

function PausedSubstate:draw()
    love.graphics.printf("[ Paused ]", self.fontPausedTitle, 0, 300, shove.getViewportWidth(), "center")

    love.graphics.printf("Press [ENTER] continue\nPress [ESCAPE] to exit", self.fontPaused, 0, 500, shove.getViewportWidth(), "center")
end

return PausedSubstate
