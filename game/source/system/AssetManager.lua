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
        data = {
            quadsData = {},
            misc = {},
        }
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

    local percentage = math.floor((shove.getViewportWidth() - 64) * LoadingState.percentage)
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
    for key, image in pairs(pool.images.static) do
        if image.setFilter then
            image:setFilter("nearest", "nearest")
        end
    end
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

function AssetManager.loadFont(key, path)
    local namespace, assetKey = getNamespace(key)
    AssetManager.assets[namespace].fonts.paths[assetKey] = path
    --loveloader.read(AssetManager.assets[namespace].fonts.paths, assetKey, path)
end

function AssetManager.loadSpritesheet(key, pathimg, pathjson)
    local namespace, assetKey = getNamespace(key)
    loveloader.newImage(AssetManager.assets[namespace].images.spritesheet, assetKey, path)
    loveloader.newImage(AssetManager.assets[namespace].data.quadsData, assetKey, pathimg, pathjson)
end

---------------------------------------------------------------------
-- get functions ---
---------------------------------------------------------------------

---Get a sprite from the asset manager
---@param key string
---@return love.Drawable
function AssetManager.getImage(key)
    local namespace, assetKey = getNamespace(key)
    return AssetManager.assets[namespace].images.static[assetKey]
end

---Get a audio from the asset manager
---@param key string
---@return love.Source
function AssetManager.getAudio(key)
    local namespace, assetKey = getNamespace(key)

    if AssetManager.assets[namespace].audios[AssetManager.AudioMode.STATIC][assetKey] then
        return AssetManager.assets[namespace].audios[AssetManager.AudioMode.STATIC][assetKey]
    elseif AssetManager.assets[namespace].audios[AssetManager.AudioMode.STREAM][assetKey] then
        return AssetManager.assets[namespace].audios[AssetManager.AudioMode.STREAM][assetKey]
    end
end

function AssetManager.getFont(key, size)
    local namespace, assetKey = getNamespace(key)

    if not table.pcontains(AssetManager.assets[namespace].fonts.paths, assetKey) then
        error(string.format("[ERROR] : The font %s is not on the path", _name))
    end

    local namedata = assetKey .. "-" .. size
    if AssetManager.assets[namespace].fonts.pool[namedata] then
        return AssetManager.assets[namespace].fonts.pool[namedata]
    else
        AssetManager.assets[namespace].fonts.pool[namedata] = love.graphics.newFont(AssetManager.assets[namespace].fonts.paths[key], size)
        return AssetManager.assets[namespace].fonts.pool[namedata]
    end
end

function AssetManager.release()
    for namespace, pool in pairs(AssetManager.assets) do
        for key, image in pairs(pool.images.static) do
            if image.release then
                image:release()
                if love.FEATURE_FLAGS.debug then
                    io.printf(string.format(
                        "{bgBrightMagenta}{brightCyan}{bold}[Love.AssetManager]{reset}{white} : Image released with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}",
                        key
                    ))
                end
            end
        end
        for key, image in pairs(pool.images.spritesheet) do
            if type(image) == "table" then
                table.clear(image)
            else
                if image.release then
                    image:release()
                    if love.FEATURE_FLAGS.debug then
                        io.printf(string.format(
                            "{bgBrightMagenta}{brightCyan}{bold}[Love.AssetManager]{reset}{white} : Image released with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}",
                            key
                        ))
                    end
                end
            end
        end

        for key, audio in pairs(pool.audios.static) do
            if audio.release then
                audio:release()
                if love.FEATURE_FLAGS.debug then
                    io.printf(string.format(
                        "{bgBrightMagenta}{brightCyan}{bold}[Love.AssetManager]{reset}{white} : Audio released with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}",
                        key
                    ))
                end
            end
        end
        for key, audio in pairs(pool.audios.stream) do
            if audio.release then
                audio:release()
                if love.FEATURE_FLAGS.debug then
                    io.printf(string.format(
                        "{bgBrightMagenta}{brightCyan}{bold}[Love.AssetManager]{reset}{white} : Audio released with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}",
                        key
                    ))
                end
            end
        end

        for key, font in pairs(pool.fonts.pool) do
            if font.release then
                font:release()
                if love.FEATURE_FLAGS.debug then
                    io.printf(string.format(
                        "{bgBrightMagenta}{brightCyan}{bold}[Love.AssetManager]{reset}{white} : Font released with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}",
                        key
                    ))
                end
            end
        end

        table.clear(pool.data.misc)
    end
end

return AssetManager
