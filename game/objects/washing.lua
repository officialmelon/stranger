--// Washing
local utils = require("utils.utils")
local world = require("game.systems.world")
local Washing = {}

local img = utils.setup_img("assets/sprites/enviroment/washing/basket.png")
local img2 = utils.setup_img("assets/sprites/enviroment/washing/washing.png")

local sprites = {
    ["basket"]   = world.createObject(img),
    ["washing"] = world.createObject(img2)
}

function Washing.create(x, y, type)
    world.insertObjectIntoEnviroment(sprites[type] or sprites["washing"], x, y, 1.25, 3)
end

return Washing