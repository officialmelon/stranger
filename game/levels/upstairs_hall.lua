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

    door.create(300, 305, "bedroom", true, {x=950,y=475})
    door.create(900, 305, "bedroom_2", false, {x=100,y=475})

    painting.create(610, 325)

    staircase.create(-995, 107, "downstairs_hall", false, {x=670,y=475}, true, true)
    vent.create(620, 550, "upstairs_hall", {x=800,y=475})

    wall.create(-1000, -15)
    wall.create(1755, -17)
    floor.create(-1000, 625, 1500)
    window.create(-100, 275)

    window.create(1350, 275)

end

function level.update(dt)
    
end

function level.kill()
    
end

return level