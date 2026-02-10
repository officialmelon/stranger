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
local plants = require("game.objects.plants")
local vent = require("game.objects.vent")
local couch = require("game.objects.couch")
local staircase = require("game.objects.staircase")

local mug = require("game.objects.items.mug")

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(15, 475)

    --// map creation

    staircase.create(820, 100, "upstairs_hall", false, {x=-400,y=475})

    door.create(-300, 305, "dining_kitchen", false, {x=-800,y=475}, true)
    door.create(400, 305, "living_room", false, {x=1000,y=475}, true)
    dresser.create(0, 470, true)
    wall.create(-1000, -15)
    wall.create(1360, -17)
    floor.create(-1000, 625, 1250)
    window.create(-700, 275)

    plants.create(130, 350)
end

function level.update(dt)
    
end

function level.kill()
    
end

return level