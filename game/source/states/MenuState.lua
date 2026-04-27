MenuState = {}

local beat = 0
local Conductor = require 'source.game.Conductor'
local Event = require 'source.game.Event'

local colors = {
    fg = { lume.color("#ffb84a") },
    bg = { lume.color("#0e0421") }
}

function MenuState:enter()
    self["logo"] = assetManager.getImage("main_logo")

    self.canPlay = false

    --self.psBG = require('src.Modules.Game.Props.ParticleSystems.MenuParticles')()
    love.graphics.setBackgroundColor(colors.bg)

    self.logoAngle = 0
    self.logoBeat = 3.45

    self.fontOptions = assetManager.getFont("monogram", 80)
    self.fontCreds = assetManager.getFont("monogram", 39)

    self.song = assetManager.getAudio("msc_future_base")

    self.camera = camera(shove.getViewportWidth() * 0.5, -shove.getViewportWidth())

    Event.hook(Conductor, { "beatHit" })
    Conductor.beatHit = function()
        if MenuState.beatHit then
            MenuState.beatHit(MenuState)
        end
    end


    Conductor.bpm = 90.75
    Conductor.songPos = 0

    self.song:setLooping(true)
    self.song:setVolume(0.65)
    self.song:play()

    flux.to(self.camera, 2.5, { y = shove.getViewportHeight() * 0.5 })
        :ease("backinout")
        :delay(0.076)
        :oncomplete(function() self.canPlay = true end)

    self.currentOption = 1
    self.startY = shove.getViewportHeight() * 0.5 - 100
    self.options = {
        "play",
        "exit"
    }
end

function MenuState:draw()
    self.camera:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
    love.graphics.draw(self["logo"],
        shove.getViewportWidth() * 0.5,
        shove.getViewportHeight() * 0.5 - 200,
        math.rad(self.logoAngle),
        self.logoBeat, self.logoBeat,
        self["logo"]:getWidth() * 0.5,
        self["logo"]:getHeight() * 0.5
    )

    --love.graphics.rectangle("fill", shove.getViewportWidth() * 0.5 - 512 * 0.5, shove.getViewportHeight() * 0.5, 512, 200, 16, 16)

    local spacing = 24
    for idx, option in ipairs(self.options) do
        local posY = self.startY + (self.fontOptions:getHeight() + spacing) * idx
        if self.currentOption == idx then
            love.graphics.setColor(colors.fg)
            love.graphics.rectangle("fill", shove.getViewportWidth() * 0.5 - (self.fontOptions:getWidth(option) + 16) / 2, posY + 8, self.fontOptions:getWidth(option) + 16, self.fontOptions:getHeight() + 8)
            love.graphics.setColor(colors.bg)
        else
            love.graphics.setColor(colors.fg)
        end
        love.graphics.printf(option, self.fontOptions, 0, posY, shove.getViewportWidth(), "center")

        love.graphics.setColor(colors.fg)
        love.graphics.printf("Created for B1T Jam 2026 | NimbusEclipse and Rato.dev (arts and thingies)", self.fontCreds, 0, shove.getViewportHeight() - (self.fontCreds:getHeight() + 8), shove.getViewportWidth(), "right")
        love.graphics.setColor(1, 1, 1, 1)
    end
    self.camera:detach()
end

function MenuState:update(elapsed)
    --self.psBG:update(elapsed)
    Conductor.songPos = self.song:tell("seconds") * 1000
    Conductor:update(elapsed)
    self.logoAngle = math.wave(-10, 10, love.timer.getTime())
    self.logoBeat = math.lerp(self.logoBeat, 3.45, 0.045)
end

function MenuState:beatHit()
    beat = beat + 1

    if beat < 16 or beat > 30 then
        if beat % 2 == 0 then
            self.logoBeat = 3.8
        end
    else
        self.logoBeat = 3.75
    end
end

function MenuState:keypressed(k)
    if not self.canPlay then return end

    if k == "down" then
        self.currentOption = self.currentOption + 1
        if self.currentOption > #self.options then
            self.currentOption = 1
        end
    elseif k == "up" then
        self.currentOption = self.currentOption - 1
        if self.currentOption < 1 then
            self.currentOption = #self.options
        end
    elseif k == "return" then
        local choose = self.options[self.currentOption]
        print(choose)

        switch(choose, {
            ["play"] = function()
                self.song:stop()
                gamestate.switch(SongSelectionState)
            end,
            ["exit"] = function()
                love.event.quit()
            end
        })
    end
end

return MenuState
