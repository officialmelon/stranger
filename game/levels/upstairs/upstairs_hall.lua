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

    dresser.create(650, 470, true)

    vent.create(1750, 545, "bedroom", {x=835,y=475}, 1)
    door.create(1500, 305, "bedroom", true, {x=1000,y=475})
    door.create(150, 305, "bedroom_2", false, {x=500,y=475})
    wall.create(-1000, -15)
    wall.create(3000, -17)
    floor.create(-1000, 625, 4000)
    window.create(550, 275)
    window.create(1000, 275)

    plants.create(675, 345)
    plants.create(900 ,350, "standing_pot")

    dresser.create(2550, 485)
    couch.create(2000, 425)

    mug.create(2600, 465, true)
    staircase.create(-650, 100, "bedroom_2", false, {x=500,y=475})

end

function level.update(dt)
    
end

function level.kill()
    
end

return level