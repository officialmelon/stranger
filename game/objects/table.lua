--// Table
local utils = require("utils.utils")
local world = require("game.systems.world")
local Table = {}

local img = utils.setup_img("assets/sprites/enviroment/table/table.png")

local sprites = {
    ["table"] = world.createObject(img)
}

function Table.create(x, y)
    local instance = world.insertObjectIntoEnviroment(sprites["table"], x, y, 1.5, 3)
end

return Table