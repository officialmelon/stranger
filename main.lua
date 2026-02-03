local push = require("libraries.push.push")
local utils = require("utils.utils")
local state = require("state.state")
local editor = require("game.scenes.editor")
local camera = require("game.systems.camera")
local gameplay = require("game.scenes.gameplay")

local editorState = false

function love.load()
    utils.initWindow()
    if not editorState then
        gameplay.init() 
    else
        editor.start("bedroom_2")
    end
    gameplay.loadLevel("bedroom")
end

function love.draw()
    push:start()
    --// start drawing
    if not editorState then
        gameplay.draw()
    else
        editor.draw()
    end
    --// finish drawing
    push:finish()
end

function love.keypressed(key)
    if not editorState then
        gameplay.keypressed(key)
    end
end

function love.update(dt)
    if not editorState then
        gameplay.update(dt)
    end
    camera.update(dt)
    utils.update(dt)
    if editorState then
        editor.update(dt)
    end
end

function love.wheelmoved(x, y)
    if not editorState then return end
    editor.wheelmoved(x,y)
end