require 'source.system.ErrHandler'
require 'source.system.Run'
local gitstuff = require 'source.system.GitStuff' -- super important stuff --
assetManager = require 'source.system.AssetManager'

presence = require 'source.system.UpdatePresence'
local presenceUpdateTimer = 0

languageService = {}
languageRaw = {}

local function createUserFolders()
    --love.filesystem.createDirectory("user/")

    local filelist = {
        root = "user",
        child = {
            "created",
            "downloaded",
            "mods",
            "skins",
            "playlist",
            "converted",
        }
    }

    if love.filesystem.getInfo(filelist.root) == nil then
        love.filesystem.createDirectory(filelist.root)

        for index, folder in ipairs(filelist.child) do
            local path = string.format("%s/%s", filelist.root, folder)
            love.filesystem.createDirectory(path)
        end
    end
end

function love.initialize()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local languageManager = require 'source.system.utils.LanguageManager'

    local save = require 'source.system.utils.Save'

    love.graphics.setDefaultFilter("nearest", "nearest")


    -- temp hack --
    ditherManager = require 'source.game.Props.DitherManager'

    -- baking dither --
    for i = 1, 63, 5 do
        ditherManager.create("8x8-" .. i, "8x8", i / 63)
        print("[ENGINE] : baking dither | " .. "8x8-" .. i)
    end

    gameSave = save.new("game")

    gameSave.save = {
        user = {
            client = "",
            playlist = {},
            editors = {},
            leaderboard = {}
        },
        settings = {}
    }

    local configAPI = json.decode(love.filesystem.read("API.json"))
    discordrpc.initialize(configAPI.discord.appid, false)

    gameSave:initialize()
    --love.keyboard.setTextInput(true)
    love.keyboard.setKeyRepeat(true)

    registers = {
        statesName = {},
        isOnline = false,
        devWindow = false,
        devWindowContent = function() return end,
    }

    local code, body = https.request("https://google.com")
    registers.isOnline = code == 200

    registers.devWindowContent = function()
        Slab.BeginWindow("menuNightDev", { Title = "Development" })
        for _, value in ipairs(registers.statesName) do
            if Slab.Button(value) then
                local stateStr = string.format('gamestate.switch(%s)', value)
                loadstring(stateStr)()
            end
        end
        Slab.EndWindow()
    end

    gitstuff() -- still super important --

    -- autoload states --
    local statePath = "source/states"
    local states = love.filesystem.getDirectoryItems(statePath)
    for s = 1, #states, 1 do
        if love.filesystem.getInfo(statePath .. "/" .. states[s]).type == "file" then
            local state = "source.states." .. states[s]:gsub(".lua", "")
            require(state)
            local strName = states[s]:gsub(".lua", "")
            table.insert(registers.statesName, strName)
            if love.FEATURE_FLAGS.debug then
                local str = string.format("{bgBrightMagenta}{brightCyan}{bold}[Love.AssetManager]{reset}{brightWhite} : State {bgYellow}%s{reset}{brightWhite} loaded with {brightGreen}Sucess{reset}", strName)
                io.printf(str)
            end
        end
    end

    --love.filesystem.createDirectory("mods")

    if love.FEATURE_FLAGS.debug then
        discordrpc.ready = function(userId, username, discriminator, avatar)
            local str = string.format("{bgBrightBlue}{brightWhite}[Love.DiscordRPC]{reset}{brightWhite}: ready (%s, %s, %s, %s){reset}", userId, username, discriminator, avatar)
            io.printf(str)

            presence.largeImageKey = "placeholder"
            presence()
        end

        discordrpc.disconnected = function(errorCode, message)
            local str = string.format("{bgBrightBlue}{brightWhite}[Love.DiscordRPC]{reset}{brightRed}: disconnected (%s, %s){reset}", errorCode, message)
            io.printf(str)
        end

        discordrpc.errored = function(errorCode, message)
            local str = string.format("{bgBrightBlue}{brightWhite}[Love.DiscordRPC]{reset}{brightRed}: Error (%s, %s){reset}", errorCode, message)
            io.printf(str)
        end
    end

    createUserFolders()

    gamestate.registerEvents()

    assetManager.targetState = MenuState
    assetManager.init(require('load'))
end

function love.update(elapsed)
    presenceUpdateTimer = presenceUpdateTimer + elapsed

    if presenceUpdateTimer > 2 and registers.isOnline then
        --discordrpc.updatePresence()
        presence()
        --local str = "{bgBrightBlue}{brightWhite}[Love.DiscordRPC]{reset}{brightBlue}: updated presence{reset}"
        --io.printf(str)
        presenceUpdateTimer = 0
    end
    if registers.isOnline then
        discordrpc.runCallbacks()
    end
end

function love.quit()
    assetManager.release()
    discordrpc.shutdown()
end
