--// Chair
local utils = require("utils.utils")
local world = require("game.systems.world")
local Chair = {}

local img = utils.setup_img("assets/sprites/enviroment/chair/toppled_chair.png")

local sprites = {
    ["toppled_chair"]   = world.createObject(img)
}

function Chair.create(x, y, type)
    world.insertObjectIntoEnviroment(sprites[type] or sprites["toppled_chair"], x, y, 1.25, 3)
end

return Chair