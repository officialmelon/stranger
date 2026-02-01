local ui = {}
local interact_btn = love.graphics.newImage("assets/sprites/enviroment/interact.png")
local state = require("state.state")
local utils = require("utils.utils")
local worldspace_ui = {}

local FADE_SPEED = 6
local font = love.graphics.newFont("assets/fonts/NFPixels-Regular.ttf", 18)

function ui.create_interact_worldspace_ui(x, y, text, radius, holdTime, callback)
    local obj = {
        text = text,
        x = x,
        y = y,
        callback = callback,
        radius = radius * 10,
        holdTime = holdTime,
        held = 0,
        lock = false,
        alpha = 0
    }
    table.insert(worldspace_ui, obj)
end

function ui.draw()
    for _, interact in pairs(worldspace_ui) do
        if not interact.lock and interact.alpha > 0 then
            local imgW = interact_btn:getWidth()
            local imgH = interact_btn:getHeight()

            love.graphics.setColor(1, 1, 1, interact.alpha)
            love.graphics.draw(interact_btn, interact.x - imgW / 2, interact.y - imgH)

            if interact.text and interact.text ~= "" then
                local textW = font:getWidth(interact.text)
                love.graphics.setColor(1, 1, 1, interact.alpha)
                love.graphics.setFont(font)
                love.graphics.print(interact.text, interact.x - textW / 2, interact.y - imgH / 2 + imgH)
            end

            local barW = imgW
            local barH = 4
            local barX = interact.x - barW / 2
            local barY = interact.y + 2
            local progress = interact.held / interact.holdTime

            love.graphics.setColor(0.2, 0.2, 0.2, interact.alpha)
            love.graphics.rectangle("fill", barX, barY, barW, barH, 2)

            if progress > 0.01 then
                love.graphics.setColor(1, 1, 1, interact.alpha)
                love.graphics.rectangle("fill", barX, barY, barW * progress, barH, 2)
            end

            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function ui.update(dt)
    for i = #worldspace_ui, 1, -1 do
        local interact = worldspace_ui[i]
        if not interact.lock then
            local inRange = utils.getDistance(state.player.x, state.player.y, interact.x, interact.y) < interact.radius

            if inRange then
                interact.alpha = math.min(interact.alpha + FADE_SPEED * dt, 1)
            else
                interact.alpha = math.max(interact.alpha - FADE_SPEED * dt, 0)
            end

            if love.keyboard.isDown("f") and inRange then
                interact.held = interact.held + dt
                if interact.held >= interact.holdTime then
                    interact.callback()
                    interact.lock = true
                    table.remove(worldspace_ui, i)
                end
            else
                interact.held = 0
            end
        end
    end
end

return ui