--// Chest
local utils = require("utils.utils")
local world = require("game.systems.world")

local Chest = {}

local wall_img = utils.setup_img("assets/sprites/enviroment/wall/wall.png")

local sprites = {
    ["wall"]   = world.createObject(wall_img)
}

function Chest.create(x, y)
    local wall = sprites["wall"]

    local collisionBox = {
        x = 0,
        y = 0,
        width = 5,
        height = wall.h
    }

    world.insertObjectIntoEnviroment(wall, x, y, 1, 3, nil, collisionBox)
end


return Chest