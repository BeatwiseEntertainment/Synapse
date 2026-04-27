RatingSubstate = {}

local Shake = require 'src.Modules.Game.Shake'

local colors = {
    fg = { lume.color("#ffb84a") },
    bg = { lume.color("#0e0421") }
}

function RatingSubstate:load()
    local path = "assets/images/game/"
    self.bgpanel = love.graphics.newImage(path .. "digi_player.png")
    self.bgpanel:setFilter("nearest", "nearest")

    self.inTransition = false
    self.gradient = love.graphics.newImage(path .. "gradient_down.png")
    self.transitionScreenY = shove.getViewportWidth()

    self.disc = love.graphics.newImage(path .. "cool_disc.png")
    self.disc:setFilter("nearest", "nearest")

    self.fontRate = fontcache.getFont("monogram", 60)
    self.fontAcc = fontcache.getFont("monogram", 45)

    self.ratings = {}
    self.ratings.img = love.graphics.newImage(path .. "ratings.png")
    self.ratings.quads = love.graphics.getQuads(self.ratings.img, path .. "ratings.json", "hash")
    self.ratings.img:setFilter("nearest", "nearest")

    self.discAngle = 0

    self.ratingLetter = "f"

    self.showData = false

    self.discPanel = {
        x = shove.getViewportWidth() * 0.5,
        y = shove.getViewportHeight() * 0.5,
    }
end

function RatingSubstate:draw()
    love.graphics.draw(self.bgpanel,
        self.discPanel.x, self.discPanel.y,
        0, 5.5, 5.5,
        self.bgpanel:getWidth() * 0.5, self.bgpanel:getHeight() * 0.5
    )
    love.graphics.draw(self.disc,
        self.discPanel.x, self.discPanel.y - 100,
        math.rad(self.discAngle), 3.2, 3.2,
        self.disc:getWidth() * 0.5, self.disc:getHeight() * 0.5
    )

    local q = self.ratings.quads[self.ratingLetter]
    local _, _, qw, qh = q:getViewport()
    love.graphics.draw(self.ratings.img, q, self.discPanel.x, self.discPanel.y - 100, 0, 4.5, 4.5, qw * 0.5, qh * 0.5)

    --self.bgpanel:getWidth() * 0.5
    love.graphics.setColor(colors.fg)
    love.graphics.print(
        string.format("Amazing: %s\nPerfect: %s\nGood: %s\nOk: %s\nMisses: %s",
            PlayState.rating["awesome"], PlayState.rating["perfect"],
            PlayState.rating["good"], PlayState.rating["ok"],
            PlayState.rating["miss"]
        ),
        self.fontRate, 100, 200
    )

    love.graphics.printf("Press [ENTER] to return to menu", self.fontRate, 0, shove.getViewportHeight() - self.fontRate:getHeight() - 8, shove.getViewportWidth(), "center")

    love.graphics.setColor(colors.bg)
    local acc = string.format("Accuracy: %.2f%%", (PlayState.accuracy or 0) * 100)
    love.graphics.print(string.format("Score: %06d", (PlayState.score or 0)), self.fontAcc,
        self.discPanel.x - self.fontAcc:getWidth(string.format("Score: %06d", PlayState.score or 0)) * 0.5, self.discPanel.y + 200
    )
    love.graphics.print(acc, self.fontAcc,
        self.discPanel.x - self.fontAcc:getWidth(acc) * 0.5, self.discPanel.y + 230
    )
    love.graphics.setColor(1, 1, 1, 1)


    love.graphics.draw(self.gradient, 0, self.transitionScreenY, 0, 1, 1)
    love.graphics.setColor(colors.bg)
    love.graphics.rectangle("fill", 0, self.gradient:getHeight() + self.transitionScreenY, shove.getViewportWidth(), shove.getViewportHeight() * 2)
    love.graphics.setColor(1, 1, 1, 1)
end

function RatingSubstate:update(elapsed)
    self.discAngle = self.discAngle - 20 * elapsed
    Shake:update(elapsed)
end

function RatingSubstate:transitionate()
    flux.to(self, 2, { transitionScreenY = -self.gradient:getHeight() })
        :oncomplete(function()
            if not gameSave.save.user.leaderboard[PlayState.songName] then
                gameSave.save.user.leaderboard[PlayState.songName] = {}
            end

            table.insert(gameSave.save.user.leaderboard[PlayState.songName], PlayState.score or 0)
            table.sort(gameSave.save.user.leaderboard[PlayState.songName], function(a, b)
                return a > b
            end)
            gameSave:saveSlot()
            gamestate.switch(SongSelectionState)
        end)
end

return RatingSubstate