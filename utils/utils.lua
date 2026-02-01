local utils = {}

local state = require("state.state")
local push = require("libraries.push.push")

function utils.clamp(low, n, high) 
    return math.min(math.max(n, low), high) 
end

function utils.setup_img(img_link)
    local img = love.graphics.newImage(img_link)
    img:setFilter("nearest", "nearest")
    return img
end

function utils.debugDraw()
    --// draw obj
    local world = state.world["WorldObj"]
    if not world then return end
    local items, len = world:getItems()
    for i = 1, len do
    local x, y, w, h = world:getRect(items[i])
    love.graphics.rectangle("line", x, y, w, h)
    end
end

function utils.initWindow()
    local w, h = love.window.getDesktopDimensions()
    local windowWidth, windowHeight = w * 0.7, h * 0.7
    push:setupScreen(1280, 720, windowWidth, windowHeight, {fullscreen = false})
end

function utils.getDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx*dx + dy*dy)
end

function utils.getObjectCenter(obj)
    local centerX = obj.x + (obj.obj.w * obj.scale) / 2
    local centerY = obj.y + (obj.obj.h * obj.scale) / 2
    return centerX, centerY
end

return utils