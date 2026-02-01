local world = require("game.systems.world")
local player = require("game.systems.player")
local utils = require("utils.utils")

local level = {}

function level.load()
    world.clear()

    player.goTo(0, 475)

    --// Level objects

    local dresser = world.createObject(utils.setup_img("assets/sprites/enviroment/dresser.png"))
    world.insertObjectIntoEnviroment(dresser, 300, 470, 1.25, 3)

    local lamp = world.createObject(utils.setup_img("assets/sprites/enviroment/desk_lamp.png"))
    world.insertObjectIntoEnviroment(lamp, 320, 385, 1.25, 2)

    local painting = world.createObject(utils.setup_img("assets/sprites/enviroment/blacked_out_painting.png"))
    world.insertObjectIntoEnviroment(painting, 600, 250, 1.25, 2)

    local planks = world.createObject(utils.setup_img("assets/sprites/enviroment/looping_planks.png"))
    world.insertObjectIntoEnviroment(planks, 0, 625, 1, 2)

    local planks = world.createObject(utils.setup_img("assets/sprites/enviroment/looping_planks.png"))
    world.insertObjectIntoEnviroment(planks, 394, 625, 1, 2)

    local planks = world.createObject(utils.setup_img("assets/sprites/enviroment/looping_planks.png"))
    world.insertObjectIntoEnviroment(planks, 788, 625, 1, 2)

    local planks = world.createObject(utils.setup_img("assets/sprites/enviroment/looping_planks.png"))
    world.insertObjectIntoEnviroment(planks, 1182, 625, 1, 2)
end

return level