DebugState = {}

local colors = {
    fg = { lume.color("#ffb84a") },
    bg = { lume.color("#0e0421") }
}

function DebugState:enter()
    self.ratingScreen = require 'source.states.Substates.RatingSubstate'
    self.ratingScreen:load()
    self.ratingScreen.ratingLetter = "s"
end

function DebugState:draw()
    self.ratingScreen:draw()
end

function DebugState:update(elapsed)
    self.ratingScreen:update(elapsed)
end

return DebugState
