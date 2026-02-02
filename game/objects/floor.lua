--// Floor
local utils = require("utils.utils")
local world = require("game.systems.world")
local Planks = {}

local planksimg = utils.setup_img("assets/sprites/enviroment/floor/looping_planks.png")

local sprites = {
    ["planks"] = world.createObject(planksimg),
}

function Planks.create(x, y, loopTo)
    world.insertObjectIntoEnviroment(sprites["planks"], x, y, 1, 2, loopTo)
end

return Planks