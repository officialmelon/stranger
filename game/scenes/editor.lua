local editor = {}
--// yes, the entire editor is in one script
--// why? fuck you thats why.
--// haha im so funny
local state = require("state.state")
local camera = require("game.systems.camera")
local world = require("game.systems.world")
local gameplay = require("game.scenes.gameplay")
local editorCameraTarget = { x = 0, y = 0 }

--// other
function editor.start()
    gameplay.loadLevel("level1") 
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
end

function editor.draw()
    camera.apply()
    world.draw()
    camera.pop()
end

return editor