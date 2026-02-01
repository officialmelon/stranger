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
    assert(image)

    return {
        image = image,
        w = image:getWidth(),
        h = image:getHeight(),

        draw = function(self, x, y, scale)
            scale = scale or 1
             love.graphics.draw(self.image, x, y, 0, scale, scale)
        end
    }
end

function World.clear()
    state.world["Enviroment"]["Objects"] = {}
end

--// Handlers

function World.update(dt)
    worldObj:update(dt)
end

function World.draw()
    local objects = state.world["Enviroment"]["Objects"]
    table.sort(objects, function(a, b) return a.zindex < b.zindex end)

    for _, obj in ipairs(objects) do
        obj.obj:draw(obj.x, obj.y, obj.scale)
    end
end

return World