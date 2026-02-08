local effects = {}

local state = require("state.state")

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

local function radialVignette(radius, vignetteSize)
    local size = radius * 2
    local data = love.image.newImageData(size, size)
    data:mapPixel(function(x, y)
        local dist = distance(radius, radius, x, y)
        local alpha = 0
        if dist <= radius then
            local adjustedDist = dist * vignetteSize
            alpha = scale(adjustedDist, 0, radius, 0, 1)
            alpha = math.min(alpha, 1)
        else
            alpha = 1
        end
        return 0, 0, 0, alpha
    end)
    return love.graphics.newImage(data)
end

--// actual logic

effects.effect_table = {
    vingette = {
        obj = nil,
        enabled = true,
        currentSize = 1,
        draw = function()
            local vignetteSize = state.world.Lighting.vignetteSize or state.world.Lighting.defaultVignetteSize
            
            if not effects.effect_table.vingette.obj or 
               effects.effect_table.vingette.currentSize ~= vignetteSize then
                effects.effect_table.vingette.obj = radialVignette(
                    math.max(gameWidth, gameHeight) / 2, 
                    vignetteSize
                )
                effects.effect_table.vingette.currentSize = vignetteSize
            end
            
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(
                effects.effect_table.vingette.obj,
                gameWidth / 2 - effects.effect_table.vingette.obj:getWidth() / 2,
                gameHeight / 2 - effects.effect_table.vingette.obj:getHeight() / 2
            )
        end
    },
    flash = {
        enabled = true,
        intensity = 0,
        draw = function()
            if effects.effect_table.flash.intensity > 0 then
                love.graphics.setColor(1, 1, 1, effects.effect_table.flash.intensity)
                love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
                effects.effect_table.flash.intensity = math.max(0, effects.effect_table.flash.intensity - love.timer.getDelta() * 2)
            end
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