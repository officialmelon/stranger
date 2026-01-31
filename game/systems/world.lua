local World = {}

--// Modules
local state = require("state.state")
local utils = require("utils.utils")

--// Control the world!

local worldObj = state.world["WorldObj"]

function World.insertObjectIntoEnviroment(object, x, y, scale, zindex)
    zindex = zindex or 1
    scale = scale or 1
    x = x or 0
    y = y or 0

    assert(object)

    local newObj = {
        obj = object,
        x = x,
        y = y,
        scale = scale,
        zindex = zindex,
    }

    table.insert(state.world["Enviroment"]["Objects"], newObj)
end

--// Object

function World.createObject(image)

end

--// Handlers

function World.update(dt)
    worldObj:update(dt)
end

function World.draw()
    utils.debugDraw()
end

return World