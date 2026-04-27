local DitherManager = {}

DitherManager.baked = {}
DitherManager.count = 0

-- create a new baked dither image --
function DitherManager.create(tag, matrix, alpha)
    local matrixes = {
        ["2x2"] = {
            { 0, 2 },
            { 3, 1 }
        },
        ["4x4"] = {
            { 0,  8,  2,  10 },
            { 12, 4,  14, 6 },
            { 3,  11, 1,  9 },
            { 15, 7,  13, 5 }
        },
        ["8x8"] = {
            { 0,  32, 8,  40, 2,  34, 10, 42 },
            { 48, 16, 56, 24, 50, 18, 58, 26 },
            { 12, 44, 4,  36, 14, 46, 6,  38 },
            { 60, 28, 52, 20, 62, 30, 54, 22 },
            { 3,  35, 11, 43, 1,  33, 9,  41 },
            { 51, 19, 59, 27, 49, 17, 57, 25 },
            { 15, 47, 7,  39, 13, 45, 5,  37 },
            { 63, 31, 55, 23, 61, 29, 53, 21 }
        }
    }

    local w, h = shove.getViewportDimensions()
    local imgData = love.image.newImageData(w, h)

    local m = matrixes[matrix]
    local size = #m
    local max = size * size

    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local threshold = m[(y % size) + 1][(x % size) + 1]

            if alpha > (threshold / max) then
                imgData:setPixel(x, y, 1, 1, 1, 1)
            else
                imgData:setPixel(x, y, 0, 0, 0, 0)
            end
        end
    end

    DitherManager.baked[tag] = love.graphics.newImage(imgData)
    DitherManager.count = DitherManager.count + 1
end

function DitherManager.getBaked(tag)
    if DitherManager.baked[tag] then
        return DitherManager.baked[tag]
    end
end

function DitherManager.release()
    for index, value in pairs(DitherManager.baked) do
        value:release()
    end
end

return DitherManager