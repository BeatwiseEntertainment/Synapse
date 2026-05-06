return function()
    camera = require 'source.system.libraries.camera'
    collision = require 'source.system.libraries.collision'
    flux = require 'source.system.libraries.flux'
    baton = require 'source.system.utils.Baton'
    Slab = require 'source.system.utils.Slab'
    moonshine = require 'source.system.Moonshine'
    loveframes = require 'source.system.utils.Loveframes'
    lume = require 'source.system.libraries.lume'
    multouch = require 'source.system.libraries.multouch'
    if love.system.getDeviceType() == "desktop" then
        discordrpc = require 'source.system.libraries.discordRPC'
        https = require 'https'
    end
    --require 'source.system.libraries.autobatch'
end
