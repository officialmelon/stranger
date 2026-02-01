local ui = {}

local bar_offset = { x = 5, y = 10 }
local gameWidth, gameHeight = 1280, 720

local slot = love.graphics.newImage("assets/sprites/hud/slot.png")
local pause = love.graphics.newImage("assets/sprites/hud/pause.png")
local mic = love.graphics.newImage("assets/sprites/hud/microphone.png")
local mic_color = love.graphics.newImage("assets/sprites/hud/microphone_color.png")


local microphone = require("game.systems.mic")

local micX, micY = 1200, 550
local scale = 2
local w, h = mic:getWidth() * scale, mic:getHeight() * scale

local font = love.graphics.newFont("assets/fonts/NFPixels-Regular.ttf", 24)

local vol = 0
local displayVol = 0

local storedTexts = {}

function ui.displayText(x, y, text)
	table.insert(storedTexts, {
		text = text,
		x=x,
		y=y
	})

	return {
			remove = function()
				for i, v in ipairs(storedTexts) do
					if v.text == text then
						table.remove(storedTexts, i)
						break
					end
				end
			end
		}
end

function ui.draw()
	for i = 1, 5 do
		love.graphics.draw(slot, bar_offset.x + (i * 60), bar_offset.y)
	end

	love.graphics.draw(pause, gameWidth - pause:getWidth(), 10)
	love.graphics.draw(mic, micX, micY, 0, scale, scale)

	local filledHeight = h * displayVol
	love.graphics.setScissor(micX, micY + h - filledHeight, w, filledHeight)
	love.graphics.draw(mic_color, micX, micY, 0, scale, scale)
	love.graphics.setScissor()

	for _, textObj in pairs(storedTexts) do
		print(textObj.text)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(font)
        love.graphics.print(textObj.text, textObj.x, textObj.y)
	end
end

function ui.update(dt)
	vol = math.min(microphone.getMicVolume() * 10, 1)
	local smoothSpeed = 8
	displayVol = displayVol + (vol - displayVol) * smoothSpeed * dt
end

return ui