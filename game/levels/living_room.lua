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

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(15, 475)

    --// map creation

    door.create(1000, 305, "downstairs_hall", false, {x=400,y=475}, true)

    couch.create(0, 415)

    dresser.create(-165,485)
    plants.create(-100, 365, "standing_pot")

    vent.create(-760,550, "bathroom", {x=185, y=475}, 7)

    door.create(-950, 305, "bathroom", true, {x=10,y=475}, false)

    window.create(-145,300)

    wall.create(-1000, -15)
    wall.create(1365, -17)
    floor.create(-1000, 625, 1300)

end

function level.update(dt)
    
end

function level.kill()
    
end

return level