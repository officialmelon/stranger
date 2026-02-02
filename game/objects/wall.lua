--// Chest
local utils = require("utils.utils")
local world = require("game.systems.world")

local Chest = {}

local wall_img = utils.setup_img("assets/sprites/enviroment/wall/wall.png")

local sprites = {
    ["wall"]   = world.createObject(wall_img)
}

function Chest.create(x, y)
    local collisionBox = {
        x = -100, --// offset for colliding with edge
        y = 0, --// offset
        width = wall_img:getWidth(),
        height = wall_img:getHeight()
    }
    world.insertObjectIntoEnviroment(sprites["wall"], x, y, 1, 3, nil, collisionBox)
end

return Chest