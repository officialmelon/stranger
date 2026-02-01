local World = {}

--// Modules
local state = require("state.state")
local utils = require("utils.utils")

--// Control the world!

local worldObj = state.world["WorldObj"]

function World.insertObjectIntoEnviroment(object, x, y, scale, zindex, loopX)
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
        loopToX = loopX
    }

    table.insert(state.world["Enviroment"]["Objects"], newObj)

    return newObj
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
        if obj.loopToX then
            local imgW = obj.obj.w * obj.scale
            local x = obj.x

            while x < obj.loopToX do
                obj.obj:draw(x, obj.y, obj.scale)
                x = x + imgW
            end
        else
            obj.obj:draw(obj.x, obj.y, obj.scale)
        end
    end
end

return World