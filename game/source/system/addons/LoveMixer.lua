love.mixer = {}

---@class MixerChannel
---@field playing boolean
---@field volume number
---@field looping boolean
---@field pitch number
---@field tags table<string>
local MixerChannel = {}
MixerChannel.__index = MixerChannel

function MixerChannel.new()
    local self = setmetatable({}, MixerChannel)
    self.type = "channel"
    self.playing = false
    self.looping = false
    self.volume = 1
    self.pitch = 1
    self.tag = ""
    return self
end

local function updateSourceSettings(source, channel)
    source:setLooping(channel.looping)
    source:setVolume(channel.volume)
    source:setPitch(channel.pitch)
end

---@class Mixer
---@field sourceCount number
---@field channelCount number
---@field maxSources number
---@field sources table<love.Source>
---@field channels table<MixerChannel>
local Mixer = {}
Mixer.__index = Mixer

function Mixer.new()
    local self = setmetatable({}, Mixer)
    self.sourceCount = 0
    self.channelCount = 0
    self.maxSources = 0
    self.sources = {}
    self.channels = {}
    return self
end

function Mixer:addSource(source, tag)
    assert(type(source) == "userdata", "[LoveMixer] : Invalid type, expected 'source', got: " .. type(source))
    self.sourceCount = self.sourceCount + 1

    if self.sourceCount > self.maxSources then
        error("[LoveMixer] : You have reached the max allowed source count, please increase the source count or remove some sources!")
        return
    end

    tag = tag or "Source_" .. self.sourceCount
    self.sources[tag] = source
end

function Mixer:addChannel(channel, tag)
    assert(channel.type == "channel", "[LoveMixer] : Invalid type, expected 'channel', got: " .. type(channel))
    self.channelCount = self.channelCount + 1

    tag = tag or "Channel_" .. self.channelCount
    self.channels[tag] = channel
end

function Mixer:getChannelVolume(channel)
    if not self.channels[channel] then return end

    return self.channels[channel].volume
end

function Mixer:setChannelVolume(channel, value)
    if not self.channels[channel] then return end

    self.channels[channel].volume = value
end

function Mixer:getChannelPitch(channel)
    if not self.channels[channel] then return end

    return self.channels[channel].pitch
end

function Mixer:setChannelPitch(channel, value)
    if not self.channels[channel] then return end

    self.channels[channel].pitch = value
end

function Mixer:getChannelLoop(channel)
    if not self.channels[channel] then return end

    return self.channels[channel].looping
end

function Mixer:setChannelLoop(channel, value)
    if not self.channels[channel] then return end

    self.channels[channel].looping = value
end

function Mixer:playChannel(channel, tag)
    self.channels[channel].tag = tag
    self.sources[tag]:play()
    self.channels[channel].playing = self.sources[tag]:isPlaying()
end

function Mixer:pauseChannel(channel, tag)
    self.channels[channel].tag = tag
    self.sources[tag]:pause()
    self.channels[channel].playing = self.sources[tag]:isPlaying()
end

function Mixer:stopChannel(channel, tag)
    self.sources[tag]:stop()
    self.channels[channel].playing = self.sources[tag]:isPlaying()
    self.channels[channel].tag = ""
end

function Mixer:play(tag)
    if self.sources[tag] then
        self.sources[tag]:play()
    end
end

function Mixer:stop(tag)
    if self.sources[tag] then
        self.sources[tag]:stop()
    end
end

function Mixer:pause(tag)
    if self.sources[tag] then
        self.sources[tag]:pause()
    end
end

---update the mixer management
function Mixer:update()
    if self.channelCount <= 0 then return end
    for name, channel in pairs(self.channels) do
        if self.sources[channel.tag] then
            updateSourceSettings(self.sources[channel.tag], channel)
        end
    end
end

---create a new instance of a mixer
---@param maxSources number
---@return Mixer
function love.mixer.newMixer(maxSources)
    maxSources = maxSources or 4
    local m = Mixer.new()
    m.maxSources = maxSources
    return m
end

---Create a new channel to be used in mixer
---@return MixerChannel
function love.mixer.newChannel()
    return MixerChannel.new()
end

return love.mixer
