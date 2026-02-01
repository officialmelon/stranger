local player = require("game.systems.player")
local state = require("state.state")
local push = require("libraries.push.push")
local ui = require("ui.ui")
local mic = require("game.systems.mic")

local world = require("game.systems.world")
local level1 = require("game.levels.level1")

local gameWidth, gameHeight = 1280, 720
local windowWidth, windowHeight
local vignette

local cameraX = 0

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

function love.load()
    windowWidth, windowHeight = love.window.getDesktopDimensions()
    windowWidth, windowHeight = windowWidth * 0.7, windowHeight * 0.7
    mic.init()

    level1.load()
    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})

    vignette = radialVignette(math.max(gameWidth, gameHeight) / 2)
end

function love.draw()
    push:start()
    love.graphics.push()
    love.graphics.translate(-cameraX, 0)
    world.draw()
    player.draw()
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(vignette, gameWidth / 2 - vignette:getWidth() / 2, gameHeight / 2 - vignette:getHeight() / 2)
    ui.draw(gameWidth)
    push:finish()
end

function love.update(dt)
    local targetCameraX = state.player.x - gameWidth / 2
    cameraX = cameraX + (targetCameraX - cameraX) * 1 * dt
    world.update(dt)
    ui.update(dt)
    print(mic.getMicVolume())
    player.update(dt)
end
