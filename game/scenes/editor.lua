local editor = {}
--// yes, the entire editor is in one script
--// why? fuck you thats why.
--// haha im so funny
local state = require("state.state")
local camera = require("game.systems.camera")
local world = require("game.systems.world")
local gameplay = require("game.scenes.gameplay")

local editorCameraTarget = { x = 0, y = 0 }
local weEdit = ""

--// other
function editor.start(whatAreWeEditing)
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
    gameplay.loadLevel(weEdit) 
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
end

return editor