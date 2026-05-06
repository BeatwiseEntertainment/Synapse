local lgSetColor = love.graphics.setColor

local function processQuadGroup(mode, image, sparrow)
    mode = mode or "array"
    local quads = {}

    if mode == "array" then
        for i = 1, #sparrow.frames, 1 do
            local Quad = love.graphics.newQuad(
                sparrow.frames[i].frame.x,
                sparrow.frames[i].frame.y,
                sparrow.frames[i].frame.w,
                sparrow.frames[i].frame.h,
                image
            )

            table.insert(quads, Quad)
        end
    elseif mode == "hash" then
        for key, obj in pairs(sparrow.frames) do
            if obj.trimmed then
                quads[key:gsub("%.[^.]+$", "")] = {
                    quad = love.graphics.newQuad(
                        obj.frame.x,
                        obj.frame.y,
                        obj.frame.w,
                        obj.frame.h,
                        image
                    ),
                    sw = obj.sourceSize.w,
                    sh = obj.sourceSize.h,
                    w = obj.spriteSourceSize.w,
                    h = obj.spriteSourceSize.h,
                }
            else
                quads[key:gsub("%.[^.]+$", "")] = love.graphics.newQuad(
                    obj.frame.x,
                    obj.frame.y,
                    obj.frame.w,
                    obj.frame.h,
                    image
                )
            end
        end
    else
        error(("There is no mode named '%s'"):format(mode))
    end

    return quads
end

---Load a sprite sheet as image and the json map and returns the image and the quad as selected mode
---@param mode string
---@param filename string
---@return love.Image
---@return table<love.Quad>
function love.graphics.newQuadFromImage(mode, filename)
    mode = mode or "array"
    local image = love.graphics.newImage(filename .. ".png")
    local jsonData = love.filesystem.read(filename .. ".json")
    local sparrow = json.decode(jsonData)

    local quads = processQuadGroup(mode, image, sparrow)
    return image, quads
end

---@alias QuadLoadMode
---| "hash"
---| "array"

---Get quads from filename
---@param image love.Drawable
---@param jsonData string
---@param mode QuadLoadMode
function love.graphics.getQuads(image, jsonData, mode)
    mode = mode or "array"
    local sparrow = json.decode(jsonData)

    local quads = processQuadGroup(mode, image, sparrow) -- discards the image data --
    return quads
end

function love.graphics.getQuadsFromAtlas(atlas, splitX, splitY)
    local image = love.graphics.newImage(atlas)
    splitX, splitY = splitX or image:getWidth(), splitY or image:getHeight()
    local quads = {}

    local frameWidth = image:getWidth() / splitX
    local frameHeight = image:getHeight() / splitY

    for y = 0, splitY - 1, 1 do
        for x = 0, splitX - 1, 1 do
            local quad = love.graphics.newQuad(
                x * frameWidth,
                y * frameHeight,
                math.floor(image:getWidth() / splitX),
                math.floor(image:getHeight() / splitY),
                image
            )

            table.insert(quads, quad)
        end
    end

    return image, quads
end

---@alias love.GradientDirection
---| "vertical"
---| "horizontal"

---@alias love.ColorTable table<number>

---Create a new gradient object
---@param dir love.GradientDirection
---@param colors table<love.ColorTable>
---@return love.Mesh
function love.graphics.newGradient(dir, colors)
    -- Check for direction
    local isHorizontal = true
    if dir == "vertical" then
        isHorizontal = false
    elseif dir ~= "horizontal" then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    -- Check for colors
    local colorLen = #colors
    if colorLen < 2 then
        error("color list is less than two", 2)
    end

    -- Generate mesh
    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = colors[i]
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = { x, 1, x, 1, color[1], color[2], color[3], color[4] or 1 }
            meshData[#meshData + 1] = { x, 0, x, 0, color[1], color[2], color[3], color[4] or 1 }
        end
    else
        for i = 1, colorLen do
            local color = colors[i]
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = { 0, y, 0, y, color[1], color[2], color[3], color[4] or 1 }
            meshData[#meshData + 1] = { 1, y, 1, y, color[1], color[2], color[3], color[4] or 1 }
        end
    end

    -- Resulting Mesh has 1x1 image size
    return love.graphics.newMesh(meshData, "strip", "static")
end

function love.graphics.release(tbl)
    local function releaseRecursive(tbl)
        for key, value in pairs(tbl) do
            if type(value) == "table" then
                releaseRecursive(value)
            else
                if type(value) == "userdata" and value.release then
                    value:release()
                end
            end
        end
    end

    releaseRecursive(tbl)
end

local _setColor = love.graphics.setColor

local function normalize(v)
    if v == nil then return 1 end
    if type(v) ~= "number" then
        error("Color value must be a number", 3)
    end
    if v <= 1 then
        return math.max(0, math.min(1, v))
    elseif v <= 255 then
        return v / 255
    else
        error("Color value out of range (expected 0-1 or 0-255)", 3)
    end
end

local function parseHex(hex)
    hex = hex:gsub("#", "")

    if #hex == 6 then -- RRGGBB
        local r = tonumber(hex:sub(1, 2), 16)
        local g = tonumber(hex:sub(3, 4), 16)
        local b = tonumber(hex:sub(5, 6), 16)
        return r / 255, g / 255, b / 255, 1
    elseif #hex == 8 then
        -- tenta detectar AARRGGBB vs RRGGBBAA
        local a1 = tonumber(hex:sub(1, 2), 16)
        local r1 = tonumber(hex:sub(3, 4), 16)

        -- heurística: alpha geralmente < 0x80
        local isAARRGGBB = a1 <= 0x80

        if isAARRGGBB then -- AARRGGBB
            local a = a1
            local r = r1
            local g = tonumber(hex:sub(5, 6), 16)
            local b = tonumber(hex:sub(7, 8), 16)
            return r / 255, g / 255, b / 255, a / 255
        else -- RRGGBBAA
            local r = a1
            local g = r1
            local b = tonumber(hex:sub(5, 6), 16)
            local a = tonumber(hex:sub(7, 8), 16)
            return r / 255, g / 255, b / 255, a / 255
        end
    else
        error("Invalid hex color format", 3)
    end
end

function love.graphics.useColor(hex)
    return { parseHex(hex) }
end

return love.graphics
