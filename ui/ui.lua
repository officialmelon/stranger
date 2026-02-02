local ui = {}
local state = require("state.state")
local microphone = require("game.systems.mic")

local isEditMode = state.world.isEditMode

local gameWidth, gameHeight = 1280, 720
local font = love.graphics.newFont("assets/fonts/NFPixels-Regular.ttf", 24)

local slot = love.graphics.newImage("assets/sprites/hud/slot.png")
local pause = love.graphics.newImage("assets/sprites/hud/pause.png")
local mic = love.graphics.newImage("assets/sprites/hud/microphone.png")
local mic_color = love.graphics.newImage("assets/sprites/hud/microphone_color.png")

local micX, micY = 1200, 550
local micScale = 2
local micW, micH = mic:getWidth() * micScale, mic:getHeight() * micScale

local staminaBar = { width = 250, height = 35, displayStamina = 100 }
local vol, displayVol = 0, 0
local storedTexts = {}

function ui.displayText(x, y, text)
    local entry = { text = text, x = x, y = y }
    table.insert(storedTexts, entry)
    return {
        remove = function()
            for i, v in ipairs(storedTexts) do
                if v == entry then
                    table.remove(storedTexts, i)
                    break
                end
            end
        end
    }
end

local function drawSlots()
    for i = 1, 5 do
        love.graphics.draw(slot, 5 + (i * 60), 10)
    end
end

local function drawStaminaBar()
    local barX = 25
    local barY = gameHeight - 60
    local fillRatio = staminaBar.displayStamina / state.player.maxStamina

    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", barX - 2, barY - 2, staminaBar.width + 4, staminaBar.height + 4, 3)

    love.graphics.setColor(0.15, 0.15, 0.15, 0.9)
    love.graphics.rectangle("fill", barX, barY, staminaBar.width, staminaBar.height)

    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", barX, barY, staminaBar.width * fillRatio, staminaBar.height, 3)

    love.graphics.setColor(1, 1, 1, 1)
end

local function drawMic()
    love.graphics.draw(mic, micX, micY, 0, micScale, micScale)

    local filledHeight = micH * displayVol
    love.graphics.setScissor(micX, micY + micH - filledHeight, micW, filledHeight)
    love.graphics.draw(mic_color, micX, micY, 0, micScale, micScale)
    love.graphics.setScissor()
end

local function drawTexts()
    love.graphics.setFont(font)
    for _, textObj in ipairs(storedTexts) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(textObj.text, textObj.x, textObj.y)
    end
end

function ui.draw()
    drawSlots()
    drawStaminaBar()
    love.graphics.draw(pause, gameWidth - pause:getWidth(), 10)
    drawMic()
    drawTexts()
end

function ui.update(dt)
    vol = math.min(microphone.getMicVolume() * 10, 1)
    displayVol = displayVol + (vol - displayVol) * 8 * dt
    staminaBar.displayStamina = staminaBar.displayStamina + (state.player.stamina - staminaBar.displayStamina) * 10 * dt
end

return ui