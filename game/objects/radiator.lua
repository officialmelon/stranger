--// Radiator
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")
local Radiator = {}

local img = utils.setup_img("assets/sprites/enviroment/radiator/radiator.png")

local sprites = {
    ["default"]   = world.createObject(img)
}

function Radiator.create(x, y)    
    world.insertObjectIntoEnviroment(sprites["default"], x, y, 1, 30)
end

return Radiator