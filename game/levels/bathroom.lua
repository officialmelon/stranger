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
local screwdriver = require("game.objects.items.screwdriver")

local toilet = require("game.objects.toilet")
local shower = require("game.objects.shower")
local sink = require("game.objects.bathroom_sink")

local mug = require("game.objects.items.mug")

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(15, 475)

    --// map creation

    door.create(10, 310, "living_room", true, {x=-950,y=475})

    vent.create(185, 550, "living_room", {x=-760,y=475}, 77)

    sink.create(1055,375,nil, "bathroom")

    toilet.create(850,415)

    window.create(850, 300)
    shower.create(400, 220)

    wall.create(0, -15)
    wall.create(1180, -17)
    floor.create(0, 625, 900)

end

function level.update(dt)
    
end

function level.kill()
    
end

return level