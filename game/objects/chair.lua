--// Chair
local utils = require("utils.utils")
local world = require("game.systems.world")
local Chair = {}

local img = utils.setup_img("assets/sprites/enviroment/chair/toppled_chair.png")

local sprites = {
    ["toppled_chair"]   = world.createObject(img)
}

function Chair.create(x, y, type, flipped)
    world.insertObjectIntoEnviroment(sprites[type] or sprites["toppled_chair"], x, y, 1.5, 3,nil, nil, flipped)
end

return Chair