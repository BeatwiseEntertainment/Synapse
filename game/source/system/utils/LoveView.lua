local LoveView = {}

LoveView.isEventRegistered = false
LoveView.stack = {}

local function newViewState(path, modtime)
    return {
        path = path,
        modtime = modtime or 0,
        view = nil
    }
end

local function processView(view)
    if not view then return end

    local ok, result = pcall(view)
    if not ok then
        print("[LoveView.Error]: " .. tostring(result))
        return
    end

    local new = loveframes.Create

    local ok2, err = pcall(result, new)
    if not ok2 then
        print("[LoveView.Error]: " .. tostring(err))
    end
end

local function updateView()
    if love.filesystem.isFused() then return end

    local hasChanges = false

    for _, view in ipairs(LoveView.stack) do
        local fileinfo = love.filesystem.getInfo(view.path)

        if fileinfo and fileinfo.modtime > view.modtime then
            local ok, loadedChunk = pcall(love.filesystem.load, view.path)

            if ok and loadedChunk then
                view.modtime = fileinfo.modtime
                view.view = loadedChunk
                hasChanges = true
            else
                print("[LoveView.Error]: " .. tostring(loadedChunk))
            end
        end
    end

    if hasChanges then
        loveframes.RemoveAll()

        for _, view in ipairs(LoveView.stack) do
            processView(view.view)
        end

        print("[LoveView.Log]: Rebuilt stack")
    end
end

function LoveView.unloadView()
    loveframes.RemoveAll()

    for i = #LoveView.stack, 1, -1 do
        table.remove(LoveView.stack, i)
    end
end

function LoveView.addView(path)
    local fileinfo = love.filesystem.getInfo(path)
    if not fileinfo then
        print("[LoveView.Error]: File not found: " .. path)
        return
    end

    local ok, loadedChunk = pcall(love.filesystem.load, path)

    if not ok or not loadedChunk then
        print("[LoveView.Error]: Failed to load " .. tostring(loadedChunk))
        return
    end

    local strlog = string.format("{bgBrightMagenta}{brightCyan}{bold}[Love.LoveView]{reset}{brightGreen} : Loaded file %s{reset}", path)
    --print("[LoveView.Sucess]: Loaded file: " .. path)
    io.printf(strlog)

    processView(loadedChunk)

    local view = newViewState(path, fileinfo.modtime)
    view.view = loadedChunk

    table.insert(LoveView.stack, view)
end

function LoveView.draw()
    local ok, err = pcall(loveframes.draw)
    if not ok then print(err) end
end

function LoveView.update(elapsed)
    updateView()

    local ok, err = pcall(loveframes.update, elapsed)
    if not ok then print(err) end
end

function LoveView.registerLoveframesEvents()
    if LoveView.isEventRegistered then
        return
    end

    local function blank() end
    local allowedEvents = {
        "mousepressed",
        "mousereleased",
        "wheelmoved",
        "textinput",
        "keypressed",
        "keyreleased"
    }

    local ogFuncs = {}

    for _, event in ipairs(allowedEvents) do
        ogFuncs[event] = love[event] or blank

        love[event] = function(...)
            ogFuncs[event](...)

            if loveframes[event] then
                local ok, err = pcall(loveframes[event], ...)
                if not ok then
                    print(err)
                end
            end
        end
    end

    LoveView.isEventRegistered = true
end

return LoveView
