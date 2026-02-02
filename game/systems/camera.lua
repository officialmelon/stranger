local camera = {}

--// Modules

local state = require("state.state")

--// Functions

function camera.setXY(x, y)
    local cam = state.world.Camera
    cam.x = x or cam.x
    cam.y = y or cam.y
end

function camera.setTarget(target) --// takes in table with x and y
    state.world.Camera.target = target
end

function camera.update(dt)
    local cam = state.world.Camera
    if not cam.target then return end

    local targetX = cam.target.x - (1280 / 2) / cam.scale
    local targetY = cam.target.y - (720 / 2) / cam.scale

    cam.x = cam.x + (targetX - cam.x) * cam.smooth * dt
    cam.y = cam.y + (targetY - cam.y) * cam.smooth * dt

    if cam.shake.duration > 0 then
        cam.shake.duration = cam.shake.duration - dt
        cam.shake.time = cam.shake.time + dt
    else
        cam.shake.intensity = 0
        cam.shake.time = 0
    end
end

function camera.apply()
    local cam = state.world.Camera
    local shakeX, shakeY = 0, 0

    if cam.shake.duration > 0 then
        shakeX = math.sin(cam.shake.time * 60) * cam.shake.intensity
        shakeY = math.cos(cam.shake.time * 55) * cam.shake.intensity
    end

    love.graphics.push()
    love.graphics.scale(cam.scale, cam.scale)
    love.graphics.translate(-cam.x + shakeX, -cam.y + shakeY)
end

function camera.pop()
    love.graphics.pop()
end

return camera
