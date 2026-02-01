local microphone = {}

local mic

function microphone.getMicVolume()
    if not mic or not mic:isRecording() then return 0 end

    local data = mic:getData()
    if not data then return 0 end

    local sum = 0
    local count = data:getSampleCount()
    for i = 0, count - 1 do
        local sample = data:getSample(i)
        sum = sum + math.abs(sample)
    end

    return sum / count
end

function microphone.init()
    local devices = love.audio.getRecordingDevices()
    mic = devices[1]
    mic:start()
end

return microphone
