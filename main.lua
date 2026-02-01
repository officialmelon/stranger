local push = require("libraries.push.push")
local utils = require("utils.utils")
local gameplay = require("game.scenes.gameplay")

function love.load()
    utils.initWindow()
    gameplay.init()
    gameplay.loadLevel("level1")
end

function love.draw()
    push:start()
    --// start drawing
    gameplay.draw()
    --// finish drawing
    push:finish()
end

function love.update(dt)
    gameplay.update(dt)
end
