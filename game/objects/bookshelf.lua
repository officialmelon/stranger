--// Bookshelf
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")
local Bookshelf = {}

local img_open = utils.setup_img("assets/sprites/enviroment/bookshelf/bookshelf.png")

local sprites = {
    ["default"]   = world.createObject(img_open)
}

function Bookshelf.create(x, y)    
    world.insertObjectIntoEnviroment(sprites["default"], x, y, 1, 3)
end

return Bookshelf