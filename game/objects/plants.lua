--// Plants
local utils = require("utils.utils")
local world = require("game.systems.world")
local Plants = {}

local img = utils.setup_img("assets/sprites/enviroment/plants/flower_bush.png")
local img2 = utils.setup_img("assets/sprites/enviroment/plants/standing_pot.png")

local sprites = {
    ["flower_bush_pot"]   = world.createObject(img),
    ["standing_pot"] = world.createObject(img2)
}

function Plants.create(x, y, type)
    world.insertObjectIntoEnviroment(sprites[type] or sprites["flower_bush_pot"], x, y, 1.25, 3)
end

return Plants