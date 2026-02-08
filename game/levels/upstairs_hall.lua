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

local mug = require("game.objects.items.mug")

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(15, 475)

    --// map creation

    vent.create(270, 545, "bathroom", {x=190, y=475}, 3)
    door.create(500, 305, "bedroom", false, {x=25,y=475})
    door.create(0, 305, "bathroom", false, {x=25,y=475})

    wardrobe.create(800, 200)

    painting.create(270, 250)

    staircase.create(-995, 107, "hall", false, {x=-650,y=475}, true, true)

    wall.create(-1000, -15)
    wall.create(1755, -17)
    floor.create(-1000, 625, 1500)
    window.create(-750, 275)
    window.create(1300, 275)

end

function level.update(dt)
    
end

function level.kill()
    
end

return level