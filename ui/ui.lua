local ui = {}
local state = require("state.state")
local microphone = require("game.systems.mic")
local utils = require("utils.utils")

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

local SLOT_PADDING = 6 
local SLOT_W = slot:getWidth()
local SLOT_H = slot:getHeight()

local SLOT_INNER_W = SLOT_W - SLOT_PADDING * 2
local SLOT_INNER_H = SLOT_H - SLOT_PADDING * 2

local tasks = {}

--// tasks

function ui.addTask(text)
    for i = 1, #tasks do
        if tasks[i].text == text then
            return tasks[i]
        end
    end

    local task = {
        text = text
    }

    table.insert(tasks, task)
    return task
end

function ui.removeTask(task)
    for i = #tasks, 1, -1 do
        if tasks[i] == task then
            table.remove(tasks, i)
            return true
        end
    end
    return false
end

function ui.clearTasks()
    for i = #tasks, 1, -1 do
        table.remove(tasks, i)
    end
end

--// others

local function getDelayAfterChar(text, index)
    local char = string.sub(text, index, index)
    if char == "." or char == "?" then
        local next = string.sub(text, index + 1, index + 1)
        if next ~= "." then
            return 0.4
        end
    end
    return 0.04
end

function ui.displayText(x, y, text, removeAfterSeconds, isStoryline)
    local entry = { text = text, x = x, y = y, visibleCount = 0, elapsed = 0, fullLength = #text, finished = false, removeAfter = removeAfterSeconds, removeElapsed = 0, isStoryline = isStoryline or false }
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
        local slotX = 5 + (i * 60)
        local slotY = 10

        love.graphics.draw(slot, slotX, slotY)

        local item = state.player.inventory[i]
        if item then
            local img = item.sprite
            local imgW = img:getWidth()
            local imgH = img:getHeight()

            local scale = math.min(
                SLOT_INNER_W / imgW,
                SLOT_INNER_H / imgH
            )

            local cx = slotX + SLOT_W / 2
            local cy = slotY + SLOT_H / 2

            love.graphics.draw(
                img,
                cx,
                cy,
                0,
                scale,
                scale,
                imgW / 2,
                imgH / 2
            )
        end
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
        love.graphics.print(string.sub(textObj.text, 1, textObj.visibleCount), textObj.x, textObj.y)
    end
end

local function drawTasks()
    love.graphics.setFont(font)
    love.graphics.print("Tasks:", 1000, 720 /2.2)
    love.graphics.rectangle("fill", 1000, 720 / 2, 200, 5)

    local lh = 20
    local sY = 720 / 1.95

    for i = 1, #tasks do
        love.graphics.printf(tasks[i].text, 1000, sY + (i - 1) * lh, 250)
    end
end

function ui.draw()
    drawTasks()
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

    for i = #storedTexts, 1, -1 do
        local textObj = storedTexts[i]
        if not textObj.finished then
            if textObj.isStoryline then
                state.player.isAbleToMove = false
            end
            textObj.elapsed = textObj.elapsed + dt
            local currentDelay = getDelayAfterChar(textObj.text, textObj.visibleCount)
            if textObj.elapsed >= currentDelay then
                textObj.elapsed = 0
                textObj.visibleCount = textObj.visibleCount + 1
                if textObj.visibleCount >= textObj.fullLength then
                    textObj.finished = true
                end
            end
        else
            if textObj.removeAfter then
                textObj.removeElapsed = textObj.removeElapsed + dt
                if textObj.removeElapsed >= textObj.removeAfter then
                    if textObj.isStoryline then
                        state.player.isAbleToMove = true
                    end
                    table.remove(storedTexts, i)
                end
            end
        end
    end
end

return ui