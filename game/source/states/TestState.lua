TestState = {}

function TestState:enter()

end

function TestState:draw()
    love.graphics.draw(assetManager.getImage("cursor"))
end

function TestState:update(elapsed)

end

return TestState
