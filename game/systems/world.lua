--// World.lua
local World = {}
local state = require("state.state")
local utils = require("utils.utils")

local worldObj = state.world["WorldObj"]

function World.insertObjectIntoEnviroment(object, x, y, scale, zindex, loopX, collisionBox, flipped)
    zindex = zindex or 1
    scale = scale or 1
    x = x or 0
    y = y or 0
    flipped = flipped or false
    assert(object)
    
    local newObj = {
        obj = object,
        x = x,
        y = y,
        scale = scale,
        zindex = zindex,
        loopToX = loopX,
        collision = collisionBox,
        flipped = flipped
    }
    table.insert(state.world["Enviroment"]["Objects"], newObj)
    return newObj
end
 
function World.removeObjectFromEnviroment(object)
    local objects = state.world.Enviroment.Objects

    for i = #objects, 1, -1 do
        if objects[i] == object then
            table.remove(objects, i)
            return true
        end
    end

    return false
end

function World.checkCollision(x, y, width, height)
    for _, obj in ipairs(state.world["Enviroment"]["Objects"]) do
        if obj.collision then
            local collBox = obj.collision
            local objX = obj.x + collBox.x
            local objY = obj.y + collBox.y
            local objW = collBox.width * obj.scale
            local objH = collBox.height * obj.scale
            
            if x < objX + objW and
               x + width > objX and
               y < objY + objH and
               y + height > objY then
                return true, obj
            end
        end
    end
    return false
end

--// World
function World.createObject(imageOrPeachy)
    assert(imageOrPeachy)
    
    local isPeachy = type(imageOrPeachy.update) == "function" and imageOrPeachy.draw
    
    if isPeachy then
        return {
            peachy = imageOrPeachy,
            w = imageOrPeachy:getWidth(),
            h = imageOrPeachy:getHeight(),
            isPeachy = true,
            draw = function(self, x, y, scale, flipped)
                scale = scale or 1
                flipped = flipped or false
                
                if flipped then
                    self.peachy:draw(x, y, 0, -scale, scale, self.w, 0)
                else
                    self.peachy:draw(x, y, 0, scale, scale)
                end
            end,
            update = function(self, dt)
                self.peachy:update(dt)
            end
        }
    else
        return {
            image = imageOrPeachy,
            w = imageOrPeachy:getWidth(),
            h = imageOrPeachy:getHeight(),
            isPeachy = false,
            draw = function(self, x, y, scale, flipped)
                scale = scale or 1
                flipped = flipped or false
                
                if flipped then
                    love.graphics.draw(self.image, x + self.w * scale, y, 0, -scale, scale)
                else
                    love.graphics.draw(self.image, x, y, 0, scale, scale)
                end
            end
        }
    end
end

function World.clear()
    state.world["Enviroment"]["Objects"] = {}
    state.world.windows = {}
end

function World.update(dt)
    worldObj:update(dt)

    for _, obj in ipairs(state.world["Enviroment"]["Objects"]) do
        if obj.obj.isPeachy and obj.obj.update then
            obj.obj:update(dt)
        end
    end
end

function World.draw()
    local objects = state.world["Enviroment"]["Objects"]
    table.sort(objects, function(a, b) return a.zindex < b.zindex end)
    
    for _, obj in ipairs(objects) do
        if obj.loopToX then
            local imgW = obj.obj.w * obj.scale
            local x = obj.x
            while x < obj.loopToX do
                obj.obj:draw(x, obj.y, obj.scale, obj.flipped)
                x = x + imgW
            end
        else
            obj.obj:draw(obj.x, obj.y, obj.scale, obj.flipped)
        end
    end
end

return World