local effects = {}

--// quick def

local gameWidth = 1280
local gameHeight = 720

--// effect util

local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

local function scale(x, min1, max1, min2, max2)
    return min2 + ((x - min1) / (max1 - min1)) * (max2 - min2)
end

local function radialVignette(radius)
    local size = radius * 2
    local data = love.image.newImageData(size, size)
    data:mapPixel(function(x, y)
        local dist = distance(radius, radius, x, y)
        local alpha = 0
        if dist <= radius then
            alpha = scale(dist, 0, radius, 0, 1)
        else
            alpha = 1
        end
        return 0, 0, 0, alpha
    end)
    return love.graphics.newImage(data)
end

--// actual logic

effects.effect_table = {
    --// darkened effect (gradient) around screen.
    vingette = {
        obj =  radialVignette(math.max(gameWidth, gameHeight) / 2),
        enabled = true,
        draw = function()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(
                effects.effect_table.vingette.obj,
                gameWidth / 2 - effects.effect_table.vingette.obj:getWidth() / 2,
                gameHeight / 2 - effects.effect_table.vingette.obj:getHeight() / 2
            )
        end
    }
}

function effects.draw()
    for _, effect in pairs(effects.effect_table) do
        if effect.enabled then
            effect.draw()
        end
    end
end

return effects