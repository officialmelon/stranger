local sound = {}

local sounds = {
    ["rain_thunder"] = "assets/sounds/rain_thunder.wav",
    ["footstep_1"] = "assets/sounds/footsteps/footstep_1.wav",
    ["footstep_2"] = "assets/sounds/footsteps/footstep_2.wav",
    ["item_pickup"] = "assets/sounds/pickup.wav",
    ["vent_open"] = "assets/sounds/vent_open.wav"
}

local soundsToPlay = {}

function sound.play(soundName, volume, pitch, looping)
    local soundData = sounds[soundName]
    if soundData then
        local source = love.audio.newSource(soundData, "static")
        source:setVolume(volume or 1)
        source:setPitch(pitch or 1)
        source:setLooping(looping or false)
        if looping then
            table.insert(soundsToPlay, source)
        end
        source:play()
        return source
    end
end

function sound.update(dt)
    for i = #soundsToPlay, 1, -1 do
        if not soundsToPlay[i]:isPlaying() then
            table.remove(soundsToPlay, i)
        end
    end
end

return sound