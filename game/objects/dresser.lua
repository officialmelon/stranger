--// Dresser
local utils = require("utils.utils")
local world = require("game.systems.world")
local Dresser = {}

local img = utils.setup_img("assets/sprites/enviroment/dresser/dresser.png")
local big = utils.setup_img("assets/sprites/enviroment/dresser/big_dresser.png")

local sprites = {
    ["dresser"]   = world.createObject(img),
    ["big"] = world.createObject(big)
}

function Dresser.create(x, y, large)
    if large then
        world.insertObjectIntoEnviroment(sprites["big"], x, y, 1.25, 3)
        return
    end
    local instance = world.insertObjectIntoEnviroment(sprites["dresser"], x, y, 1.25, 3)
end

return Dresser