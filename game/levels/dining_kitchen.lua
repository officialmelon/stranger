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
local wardrobe = require("game.objects.wardrobe")
local table = require("game.objects.table")
local chair = require("game.objects.chair")

local mug = require("game.objects.items.mug")
local landphone = require("game.objects.landphone")

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(15, 475)

    --// map creation

    chair.create(-350,515,"",false)
    chair.create(450,515,"",true)

    door.create(-800, 305, "downstairs_hall", false, {x=-300,y=475}, true)

    window.create(135, 325)

    table.create(0,465)

    dresser.create(700,485, true)
    plants.create(830, 360)

    window.create(1520, 325)

    cabinet.create(1520, 500, "oven")
    cabinet.create(1640, 493, "sink")
    cabinet.create(1400, 500, "pully")
    cabinet.create(1280, 500, "pully")
    cabinet.create(1755, 500, "pully")

    cabinet.create(1520, 190, "default")
    cabinet.create(1640, 190, "default")
    cabinet.create(1400, 190, "default")
    cabinet.create(1280, 190, "pully")
    cabinet.create(1755, 190, "pully")

    if state.story.isPhase(1) then
        mug.create(50, 502, true)
    end

    landphone.create(1125, 400)

    wall.create(-1000, -15)
    wall.create(2150, -17)
    floor.create(-1000, 625, 1800)

end

function level.update(dt)
    
end

function level.kill()
    
end

return level