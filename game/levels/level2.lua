local world = require("game.systems.world")
local player = require("game.systems.player")
local utils = require("utils.utils")
local ui = require("ui.ui")
local worldspace = require("ui.worldspace")
local state = require("state.state")

local chest = require("game.objects.chest")
local door = require("game.objects.door")
local bed = require("game.objects.bed")
local window = require("game.objects.window")
local wall = require("game.objects.wall")

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = 2
    player.goTo(0, 350)

    --// map creation

    door.create(0, 305, "level1", false)
    wall.create(0, 0)
    wall.create(450, 0)

    --// sits on desk

    local painting = world.createObject(utils.setup_img("assets/sprites/enviroment/blacked_out_painting.png"))
    world.insertObjectIntoEnviroment(painting, 600, 250, 1.25, 2)
        
    local planks = world.createObject(utils.setup_img("assets/sprites/enviroment/looping_planks.png"))
    world.insertObjectIntoEnviroment(planks, 0, 625, 1, 2, 450)
end

function level.update(dt)
    
end

function level.kill()
    
end

return level