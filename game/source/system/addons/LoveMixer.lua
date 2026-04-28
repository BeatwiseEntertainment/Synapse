love.mixer = {}

---@type love.MixerPlaybackOptions
love.MixerPlaybackOptions = {
    loop = false,
    pitch = 1,
    volume = 1,
}

local MixerChannel = {}
MixerChannel.__index = MixerChannel

function MixerChannel.new(maxSourceCount)
    local self = setmetatable({}, MixerChannel)
    self.volume = 1
    self.pitch = 1
    self.loop = false
    self._tags = {}
    self._sources = {}
    return self
end

function MixerChannel:_play() end

local Mixer = {}
Mixer.__index = Mixer

---Create a new mixer instance
---@param maxSourceCount integer
---@return love.Mixer
function Mixer.new(maxSourceCount)
    local self = setmetatable({}, Mixer)
    self._sourceAssets = {} ---@type record<string, love.Source>
    self._channels = {} ---@type record<string, love.MixerChannel>
    self._maxSounds = maxSourceCount ---@type integer
    self._sourcesCount = 0
    self._channelsCount = 0

    -- public --
    self.masterVolume = 1 ---@type float
    self.masterPitch = 1 ---@type float
    return self
end

---Add a new source on the mixer rack
---@param tag string
---@param source Love.Source
function Mixer:addSource(tag, source)
    self._sourcesCount = self._sourcesCount + 1

    if self._sourcesCount > self.maxSounds then
        error("[Love.Mixer] : The mixer reached the max allowed source count. maxSounds = " .. self._maxSounds)
    end

    if type(tag) == "nil" then
        tag = "snd_" .. self._sourcesCount
    end

    self._sourceAssets[tag] = source
end

---Create a new channel and attach to the rack
---@param channelName string
function Mixer:addChannel(channelName)
    if self._channels[channelName] then
        -- ignore if the channel already exists --
        return
    end

    self._channelsCount = self._channelsCount + 1

    if type(channelName) == "nil" then
        channelName = "chn_" .. self._channelsCount
    end

    local channelInstance = MixerChannel.new()
    self._channels[channelName] = channelInstance
end

function Mixer:playChannel(channelName, tag, settings)
    settings = settings or {
        loop = false,
        volume = 1,
        pitch = 1,
    }

    if type(channelName) == "nil" then
        return
    end

    if type(tag) == "nil" then
        return
    end

    local channel = self._channels[channelName]
    local sound = self._sourceAssets[tag]

    channel._sounds[tag] = sound

    channel.volume = settings.volume
    channel.pitch = settings.pitch
    channel.loop = settings.loop

    sound:play()
end

---update all values of the mixer --
function Mixer:update()
    for channelName, channel in pairs(self._channels) do
        for tag, source in pairs(channel._sounds) do
            source:setVolume(self.masterVolume * channel.volume)
            source:setPitch(channel.volume)
            source:setLooping(channelName.loop)

            if source:isPlaying() and not source:isLooping() then
                table.removeItem(channel._sounds, tag)
            end
        end
    end
end

function love.mixer.newMixer()
    return Mixer.new()
end

return love.mixer
