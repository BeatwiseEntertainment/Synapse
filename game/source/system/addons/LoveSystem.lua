---@alias love.DeviceType
---| "desktop"
---| "mobile"
---| "unknown"

---comment
---@return love.DeviceType
function love.system.getDeviceType()
    if love.system.getOS() == "Windows" or love.system.getOS() == "Linux" or love.system.getOS() == "OS X" then
        return "desktop"
    elseif love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
        return "mobile"
    end
    return "unknown"
end

return love.system
