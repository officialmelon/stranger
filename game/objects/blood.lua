--// Blood
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")
local Blood = {}

local img = utils.setup_img("assets/sprites/enviroment/blood/smear.png")

local sprites = {
    ["default"]   = world.createObject(img)
}

function Blood.create(x, y)    
    world.insertObjectIntoEnviroment(sprites["default"], x, y, 1, 30)
end

return Blood