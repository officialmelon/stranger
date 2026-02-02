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

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(0, 350)

    --// map creation

    local dresser = world.createObject(utils.setup_img("assets/sprites/enviroment/dresser.png"))
    world.insertObjectIntoEnviroment(dresser, 300, 470, 1.25, 3)

    chest.create(550, 470)
    door.create(1000, 305, "level2")
    bed.create(1400, 500, true)
    wall.create(0, 0)
    wall.create(1850, 0)

    --// sits on desk

    local lamp = world.createObject(utils.setup_img("assets/sprites/enviroment/desk_lamp.png"))
    world.insertObjectIntoEnviroment(lamp, 320, 385, 1.25, 2)

    local painting = world.createObject(utils.setup_img("assets/sprites/enviroment/blacked_out_painting.png"))
    world.insertObjectIntoEnviroment(painting, 600, 250, 1.25, 2)
    
    window.create(1250, 350)

    local planks = world.createObject(utils.setup_img("assets/sprites/enviroment/looping_planks.png"))
    world.insertObjectIntoEnviroment(planks, 0, 625, 1, 2, 1850)
end

function level.update(dt)
    
end

function level.kill()
    
end

return level