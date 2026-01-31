local player = require("game.systems.player")
local push = require("libraries.push.push")

function love.load()
    --// copied from docs
    local gameWidth, gameHeight = 1280, 720
    local windowWidth, windowHeight = love.window.getDesktopDimensions()
    windowWidth, windowHeight = windowWidth*.7, windowHeight*.7

    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})
end

function love.draw()
    push:start()
    player.draw()
    push:finish()
end

function love.update(dt)
    player.update(dt)
end