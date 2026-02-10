--// Toilet
local utils = require("utils.utils")
local world = require("game.systems.world")
local Toilet = {}

local default = utils.setup_img("assets/sprites/enviroment/toilet/toilet.png")

local sprites = {
    ["default"]   = world.createObject(default)
}

function Toilet.create(x, y)
    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y,1,6)
end

return Toilet