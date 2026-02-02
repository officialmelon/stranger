local push = require("libraries.push.push")
local utils = require("utils.utils")
local state = require("state.state")
local editor = require("game.scenes.editor")
local camera = require("game.systems.camera")

local gameplay = require("game.scenes.gameplay")
   
function love.load()
    utils.initWindow()
    gameplay.init()
    --editor.start()
    gameplay.loadLevel("level1")
end

function love.draw()
    push:start()
    --// start drawing
    --editor.draw()
    gameplay.draw()
    --// finish drawing
    push:finish()
end

function love.update(dt)
    gameplay.update(dt)
    camera.update(dt)
    utils.update(dt)
    --editor.update(dt)
end
