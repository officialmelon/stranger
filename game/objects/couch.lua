--// Couch
local utils = require("utils.utils")
local world = require("game.systems.world")
local Couch = {}

local default = utils.setup_img("assets/sprites/enviroment/couch/couch.png")

local sprites = {
    ["default"]   = world.createObject(default),
}

function Couch.create(x, y)
    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 1.5, 5)
end

return Couch