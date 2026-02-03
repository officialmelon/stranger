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
local dresser = require("game.objects.dresser")
local floor = require("game.objects.floor")
local painting = require("game.objects.painting")
local cabinet = require("game.objects.cabinet")
local vent = require("game.objects.vent")
local plants = require("game.objects.plants")

local screwdriver = require("game.objects.items.screwdriver")

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(15, 475)

    --// map creation

    dresser.create(25, 470, true)
    door.create(500, 305, "hall", false, {x=150,y=475})
    bed.create(790, 500, false, false)
    wall.create(0, -15)
    wall.create(1175, -17)
    floor.create(0, 625, 1000)
    window.create(130, 275)
    painting.create(900, 275)

    plants.create(25,350)
end

function level.update(dt)
    
end

function level.kill()
    
end

return level