GameOverSubstate = {}

local colors = {
    fg = { lume.color("#ffb84a") },
    bg = { lume.color("#0e0421") }
}

function GameOverSubstate:load()
    self.robot = love.graphics.newImage("assets/images/game/broken_robot.png")


    self.fontTitle = fontcache.getFont("monogram", 80)
    self.fontSong = fontcache.getFont("monogram", 55)
end

function GameOverSubstate:draw()
    love.graphics.draw(self.robot, 160, 300, 0, 3, 3)

    love.graphics.setColor(colors.fg)
    love.graphics.printf("[ Game Over ]", self.fontTitle, 0, 300, shove.getViewportWidth(), "center")

    love.graphics.printf("Press [ENTER] to retry\nPress [ESCAPE] to exit", self.fontSong, 0, 500, shove.getViewportWidth(), "center")
    love.graphics.setColor(1, 1, 1, 1)
end

return GameOverSubstate