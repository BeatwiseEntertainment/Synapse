local loveloader = require 'source.system.utils.LoveLoader'
local AssetManager = {}

AssetManager.mods = {}
AssetManager.targetState = nil
AssetManager.defaultLoadState = nil

---@enum AssetType
AssetManager.AssetType = {
    IMAGE = "images",
    AUDIO = "audios",
    DATA = "data",
    SPRITESHEET = "spritesheet"
}

AssetManager.SpritesheetImportMode = {
    ARRAY = "array",
    HASH = "hashs"
}

AssetManager.AudioMode = {
    STREAM = "stream",
    STATIC = "static"
}

local function newPool()
    return {
        images = {
            static = {},
            spritesheet = {},
        },
        audios = {
            static = {},
            stream = {},
        },
        fonts = {
            paths = {},
            pool = {},
        },
        shaders = {},
        data = {}
    }
end

AssetManager.assets = {
    ["builtin"] = newPool()
}

local LoadingState = {}

local icon

function LoadingState:enter()
    LoadingState.percentage = 0
    icon = love.graphics.newImage("icon.png")

    loveloader.start(function()
        gamestate.switch(assetManager.targetState)
    end, function(kind, holder, key)
        if love.FEATURE_FLAGS.debug then
            io.printf(string.format(
                "{bgBrightMagenta}{brightCyan}{bold}[Love.AssetManager]{reset}{brightWhite} : File loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}",
                key
            ))
        end
    end)
end

function LoadingState:draw()
    local width = 0
    love.graphics.draw(icon,
        shove.getViewportWidth() * 0.5, shove.getViewportHeight() * 0.5 - 150,
        0, 0.5, 0.5,
        icon:getWidth() * 0.5, icon:getHeight() * 0.5
    )

    local percentage = math.floor(shove.getViewportWidth() - 64 / (LoadingState.percentage / 100))
    love.graphics.rectangle("fill", 32, shove.getViewportHeight() - 48,
        percentage, 32
    )

    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", 32, shove.getViewportHeight() - 48, shove.getViewportWidth() - 64, 32)
    love.graphics.setLineWidth(1)
end

function LoadingState:update(elapsed)
    if loveloader.resourceCount > 0 then LoadingState.percentage = loveloader.loadedCount / loveloader.resourceCount end

    loveloader.update()
end

function LoadingState:leave(elapsed)
    icon:release()
end

---Get the current namespace from the parsed key --
---@param key string
---@return string|unknown
---@return unknown
local function getNamespace(key)
    local p = string.split(key, ":")
    local namespace, assetKey = p[1], p[2]

    if assetKey == nil then
        assetKey = namespace
        namespace = "builtin"
    end

    return namespace, assetKey
end

function AssetManager.init(def)
    love.filesystem.createDirectory("mods")

    def()
    if AssetManager.defaultLoadState == nil then
        gamestate.switch(LoadingState)
    else
        gamestate.switch(AssetManager.defaultLoadState)
    end
end

function AssetManager.onComplete() end

---------------------------------------------------------------------
-- load functions ---
---------------------------------------------------------------------
function AssetManager.loadImage(key, path)
    local namespace, assetKey = getNamespace(key)
    loveloader.newImage(AssetManager.assets[namespace].images.static, assetKey, path)
end

function AssetManager.loadAudio(key, path, audioType)
    local namespace, assetKey = getNamespace(key)
    loveloader.newSource(AssetManager.assets[namespace].audios[audioType], assetKey, path, audioType)
end

function AssetManager.loadFont()

end

---------------------------------------------------------------------
-- get functions ---
---------------------------------------------------------------------

function AssetManager.getImage(key)
    local namespace, assetKey = getNamespace(key)
    return AssetManager.assets[namespace].images.static[assetKey]
end

function AssetManager.getAudio(key, mode)
    local namespace, assetKey = getNamespace(key)
    mode = mode or AssetManager.AudioMode.STATIC
    return AssetManager.assets[namespace].audios[mode][assetKey]
end

function AssetManager.release()

end

return AssetManager
