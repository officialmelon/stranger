--// Dresser
local utils = require("utils.utils")
local world = require("game.systems.world")
local Dresser = {}

local img = utils.setup_img("assets/sprites/enviroment/dresser/dresser.png")
local lamp = utils.setup_img("assets/sprites/enviroment/dresser/desk_lamp.png")

local sprites = {
    ["dresser"]   = world.createObject(img),
    ["lamp"] = world.createObject(lamp)
}


function Dresser.create(x, y, lap)
    local instance = world.insertObjectIntoEnviroment(sprites["dresser"], x, y, 1.25, 3)
    if lap then
        world.insertObjectIntoEnviroment(sprites["lamp"], x, y + lamp:getHeight(), 1.25, 2)
    end
end

return Dresser