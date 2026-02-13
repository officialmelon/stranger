local utils = {}

local state = require("state.state")
local push = require("libraries.push.push")

local delayedCalls = {}

function utils.delay(seconds, callback)
    table.insert(delayedCalls, {
        time = seconds,
        callback = callback
    })
end

function utils.update(dt)
    for i = #delayedCalls, 1, -1 do
        local call = delayedCalls[i]
        call.time = call.time - dt

        if call.time <= 0 then
            call.callback()
            table.remove(delayedCalls, i)
        end
    end
end

function utils.clamp(low, n, high) 
    return math.min(math.max(n, low), high) 
end

function utils.setup_img(img_link)
    local img = love.graphics.newImage(img_link)
    img:setFilter("nearest", "nearest")
    return img
end

function utils.returnTextCenteredWidth(hidingMessage)
    return 1280/2 - love.graphics.getFont():getWidth(hidingMessage)/2
end

function utils.debugDraw()
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
    push:setupScreen(1280, 720, windowWidth, windowHeight, { fullscreen = false })
    love.window.setTitle( "Stranger Beta 0.1" )
    love.window.setMode(windowWidth, windowHeight, {
        resizable = false,
    })
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
