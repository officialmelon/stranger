local editor = {}
--// yes, the entire editor is in one script
--// why? fuck you thats why.
--// haha im so funny
local state = require("state.state")
local camera = require("game.systems.camera")
local world = require("game.systems.world")
local gameplay = require("game.scenes.gameplay")

local love = require("love")

local editorCameraTarget = { x = 0, y = 0 }
local weEdit = ""
local diffFolder = ""

--// other
function editor.start(whatAreWeEditing)
    love.mouse.setVisible(true)
    state.world["Camera"].scale = 0.5
    weEdit = whatAreWeEditing
end

function editor.update(dt)  
    local mx, my = love.mouse.getPosition()
    
    if love.mouse.isDown(3) then
        editorCameraTarget.x = mx / state.world.Camera.scale + state.world.Camera.x
        editorCameraTarget.y = my / state.world.Camera.scale + state.world.Camera.y
    end
    
    camera.setTarget(editorCameraTarget)
    camera.update(dt)
    world.update(dt)
    gameplay.loadLevel(weEdit, diffFolder) 
end

function editor.ui(fldr, y)
    y = y or 0
    local files = love.filesystem.getDirectoryItems(fldr)
    local mx,my = love.mouse.getPosition()
    local clicked = love.mouse.isDown(1)
    
    for i, v in ipairs(files) do
        local file = fldr.."/"..v
        local info = love.filesystem.getInfo(file)

        local isHover = mx >= 10 and mx <= 210 and my >= y and my <= y + 30
        
        if info and info.type == "file" then
            if isHover and clicked then
                weEdit = v:gsub(".lua", ""):gsub("/", ".")
                diffFolder = (fldr.."."):gsub("/", ".")
            end
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", 10, y, 200, 30)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(v, 15, y + 8)
            y = y + 35
        else  
            y = editor.ui(file, y)
        end
    end
    
    return y
end

function editor.wheelmoved(x, y)
    if y > 0 then
        state.world.Camera.scale = state.world.Camera.scale + 0.05
    else
        state.world.Camera.scale = state.world.Camera.scale - 0.05
    end
end

function editor.draw()
    camera.apply()
    world.draw()
    camera.pop()
    editor.ui("game/levels")
end

return editor