LoadingState = {}

local colors = {
    fg = { lume.color("#ffb84a") },
    bg = { lume.color("#0e0421") }
}

function LoadingState:enter()
    --loveloader.
    local load = require 'src.Modules.Game.AssetLoad'

    --load()
end

function LoadingState:draw()

end

function LoadingState:update(elapsed)

end

return LoadingState