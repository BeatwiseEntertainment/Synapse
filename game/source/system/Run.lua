fsutil = require 'source.system.utils.FSUtil'
fontcache = require 'source.system.utils.FontCache'
shove = require 'source.system.Shove'
class = require 'source.system.utils.Classic'
gamestate = require 'source.system.utils.GameState'
json = require 'source.system.utils.JSON'

love.FEATURE_FLAGS = require 'source.system.FeatureFlags'

love._FPSCap = 144
love._unfocusedFPSCap = 60
local flashOpacity = 0
love._showFPS = false

love.window.resolutionModes = {}

local modes = love.window.getFullscreenModes()

table.sort(modes, function(a, b) return a.width * a.height > b.width * b.height end) -- Ordena da maior para a menor

for i, mode in ipairs(modes) do
    love.window.resolutionModes[i] = {
        width = mode.width, height = mode.height
    }
end

modes = nil

logs = {}

-- copy all the need libraries for game to work --
local function copyLib()
    if love.filesystem.getInfo("bin") == nil then return end

    if love.system.getOS() == "Windows" then
        local dlf = love.filesystem.getDirectoryItems("assets/bin/win")
        for d = 1, #dlf, 1 do
            local filename = "/bin/" .. dlf[d]
            love.filesystem.write(filename, love.filesystem.read("assets/bin/win/" .. dlf[d]))
        end
    elseif love.system.getOS() == "OS X" then
        local dlf = love.filesystem.getDirectoryItems("assets/bin/macos")
        for d = 1, #dlf, 1 do
            local filename = "/bin/" .. dlf[d]
            love.filesystem.write(filename, love.filesystem.read("assets/bin/macos/" .. dlf[d]))
        end
    elseif love.system.getOS() == "Linux" then
        local dlf = love.filesystem.getDirectoryItems("assets/bin/linux")
        for d = 1, #dlf, 1 do
            local filename = "/bin/" .. dlf[d]
            love.filesystem.write(filename, love.filesystem.read("assets/bin/linux/" .. dlf[d]))
        end
    end

    io.printf("{bgBrightMagenta}{brightCyan}[Love.Engine]{reset}{brightWhite} : Libraries copied with sucess{reset}")
end

local ogprint = print
print = function(...)
    table.insert(_G.logs, ("[%s] %s"):format(os.date("%Y/%m/%d %H:%M:%S"), table.concat({ tostring(...) }, " ")))
    ogprint(...)
end

local function getKeys()
    local keys = {}
    for k, v in pairs(love.graphics.getStats()) do
        table.insert(keys, k)
    end
    return keys
end

love.keys = {}
love.keys.videoStats = getKeys()

local function loadAddons()
    local addons = fsutil.scanFolder("source/system/addons")
    for a = 1, #addons, 1 do
        local ad = addons[a]:gsub(".lua", "")
        print(string.format("[love.addons] : Addon '%s' loaded with sucess", ad))
        require(ad:gsub("/", "%."))
    end
end

function love.run()
    loadAddons()

    local config = json.decode(love.filesystem.read("config.json"))
    local controls = json.decode(love.filesystem.read("controls.json"))

    love.filesystem.createDirectory("bin")
    copyLib()

    local sourcePath = love.filesystem.getSaveDirectory() .. "/bin"
    --print(sourcePath)

    local newCPath = string.format(
        "%s/?.dll;%s/?.so;%s/?.dylib;%s",
        sourcePath,
        sourcePath,
        sourcePath,
        package.cpath)
    package.cpath = newCPath

    fontcache.init()
    loveView = require 'source.system.utils.LoveView'


    require('source.system.Imports')()

    Controls = baton.new({
        controls = controls,
    })

    flux.removeAll()

    love.math.setRandomSeed(os.time())
    math.randomseed(os.time())

    -- Initialize Shöve with fixed game resolution and options
    shove.setResolution(config.viewportWidth, config.viewportHeight, { fitMethod = "aspect", renderMode = "layer" })
    -- Set up a resizable window
    shove.setWindowMode(config.screenWidth, config.screenHeight,
        { resizable = config.resizable, vsync = 0, fullscreen = config.fullscreen })

    shove.createLayer("mainView", {
        stencil = true,
    })
    shove.createLayer("DevUI")
    shove.createLayer("fps")


    local SlabStyle = Slab.GetStyle()
    SlabStyle.API.Initialize()
    Slab.Initialize({ "NoDocks" })

    local fpsfont = love.graphics.newFont(16)

    if love.initialize then
        love.initialize(love.arg.parseGameArguments(arg), arg)
    end

    if love.timer then love.timer.step() end

    local elapsed = 0

    local function renderVideoStats()
        if love.FEATURE_FLAGS.videoStats then
            local stringList = {}
            local stats = love.graphics.getStats()
            for idx = 1, #love.keys.videoStats, 1 do
                local key = love.keys.videoStats[idx]
                local stat = stats[love.keys.videoStats[idx]]

                local textDisplay = string.format("%s = %s", key, stat)

                if key == "texturememory" then
                    textDisplay = string.format("%s = %s", key, string.format("%.2f mb", stat / 1024 / 1024))
                end
                stringList[idx] = textDisplay
            end
            love.graphics.print(table.concat(stringList, "\n"), fpsfont, 5, 20)
        end
    end

    -- Main loop time.
    return function()
        local startT = love.timer.getTime()

        -- Process events.
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                elseif name == "keypressed" then
                    if love.FEATURE_FLAGS.developerMode then
                        if a == "f12" then
                            love.FEATURE_FLAGS.videoStats = not love.FEATURE_FLAGS.videoStats
                        end
                        if a == "f5" then
                            registers.devWindow = not registers.devWindow
                        end
                    end
                    if love.FEATURE_FLAGS.captureScreenshot then
                        if love.keyboard.isDown("lctrl") and a == "f1" then
                            love.filesystem.createDirectory("screenshots")
                            love.graphics.captureScreenshot("screenshots/" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png")
                        end
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        local isFocused = love.window.hasFocus()

        local fpsCap = isFocused and love._FPSCap or love._unfocusedFPSCap
        if love.timer then
            elapsed = love.timer.step()
        end

        if love.update then
            love.update(elapsed)
            flux.update(elapsed)

            Controls:update()
            if love.FEATURE_FLAGS.developerMode then
                Slab.Update(elapsed)
                if registers.devWindow then
                    if registers.devWindowContent then
                        registers.devWindowContent()
                    end
                end
            end
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()

            shove.beginDraw()

            shove.beginLayer("mainView")
            if love.draw then
                love.draw()
            end
            shove.endLayer()

            if love.FEATURE_FLAGS.developerMode then
                shove.beginLayer("DevUI")
                Slab.Draw()
                shove.endLayer()
            end

            shove.beginLayer("fps")
            if love._showFPS then
                love.graphics.print("FPS : " .. love.timer.getFPS(), fpsfont, 5, 5)
            end

            renderVideoStats()

            shove.endLayer()
            shove.endDraw()

            if love.mouse.isVisible() and love.mouse.getRelativeMode() then
                love.graphics.draw(cursor, love.mouse.getX() - 4, love.mouse.getY() - 1, 0, 20 / cursor:getWidth(),
                    20 / cursor:getHeight())
            end
            love.graphics.present()
        end

        collectgarbage("collect")

        if love.timer then
            local endT = love.timer.getTime()
            love.timer.sleep(1 / fpsCap - (endT - startT))
        end
    end
end
