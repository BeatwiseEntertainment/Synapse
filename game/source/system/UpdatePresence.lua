local Presence = {
    state = "Initializing...",
    details = "Getting everything done",
    largeImageKey = "icon",
    largeImageText = "Playing Neonix!",

}

setmetatable(Presence, {
    __call = function()
        discordrpc.updatePresence(Presence)
    end
})


return Presence
