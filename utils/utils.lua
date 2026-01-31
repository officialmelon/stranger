local utils = {}

local state = require("state.state")

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

return utils