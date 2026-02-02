--// Painting
local utils = require("utils.utils")
local world = require("game.systems.world")
local Painting = {}

local img = utils.setup_img("assets/sprites/enviroment/painting/blacked_out_painting.png")

local sprites = {
    ["dresser"] = world.createObject(img)
}

function Painting.create(x, y, optionalName)
    local instance = world.insertObjectIntoEnviroment(sprites[optionalName or "dresser"], x, y, 1.25, 3)
end

return Painting