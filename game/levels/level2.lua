local world = require("game.systems.world")
local player = require("game.systems.player")
local utils = require("utils.utils")
local ui = require("ui.ui")
local worldspace = require("ui.worldspace")

local chest = require("game.objects.chest")
local door = require("game.objects.door")

local level = {}

function level.load()
    world.clear()

    player.goTo(0, 475)

    --// map creation

    local painting = world.createObject(utils.setup_img("assets/sprites/enviroment/blacked_out_painting.png"))
    world.insertObjectIntoEnviroment(painting, 600, 250, 3, 2)

    local planks = world.createObject(utils.setup_img("assets/sprites/enviroment/looping_planks.png"))
    world.insertObjectIntoEnviroment(planks, 0, 625, 1, 2, 1600)

    --// Interacts

    worldspace.create_interact_worldspace_ui(550, 470, "Hide", 25, 2, function ()
        print("SSS")
    end)
end

function level.update(dt)
    
end

function level.kill()
    
end

return level