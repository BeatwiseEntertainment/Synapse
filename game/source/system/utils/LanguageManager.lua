---@class LanguageManager
local LanguageManager = {}
LanguageManager.extension = "json"

---@private
local function _findKey(_tblInput, _tblOutput)
    for k, v in pairs(_tblInput) do
        if type(v) == "table" then
            _findKey(v, _tblOutput)
        else
            _tblOutput[k] = v
        end
    end
end

---Load a language file from the assets folder
---@param language string
---@return table
function LanguageManager.getData(language)
    local data = {}

    local tempdata = json.decode(love.filesystem.read("assets/data/language/" .. language .. "." .. LanguageManager.extension))
    _findKey(tempdata, data)
    return data
end

---Load and return a raw decoded data from the language file --
---@param language string
---@return table
function LanguageManager.getRawData(language)
    return json.decode(love.filesystem.read("assets/data/language/" .. language .. "." .. LanguageManager.extension))
end

return LanguageManager