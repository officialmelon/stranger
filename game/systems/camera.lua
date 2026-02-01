local camera = {}

--// Modules

local state = require("state.state")

--// Functions

function camera.setXY(x, y)
    local cam = state.world.Camera
    cam.x = x or cam.x
    cam.y = y or cam.y
end

function camera.update(dt)
    local cam = state.world.Camera
    local targetX = state.player.x - (1280 / 2) / state.world["Camera"].scale
    local targetY = state.player.y - (720 / 2) / state.world["Camera"].scale
    cam.x = cam.x + (targetX - cam.x) * state.world["Camera"].smooth * dt
    cam.y = cam.y + (targetY - cam.y) * state.world["Camera"].smooth * dt
end

function camera.apply()
    local cam = state.world.Camera
    love.graphics.push()
    love.graphics.scale(cam.scale, cam.scale)
    love.graphics.translate(-cam.x, -cam.y)
end

function camera.pop()
    love.graphics.pop()
end

return camera
