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
local intruderSystem = require("game.systems.intruder")

local mug = require("game.objects.items.mug")

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(15, 475)

    local bedroomLocked = true
    local bedroom2Locked = false
    local stairsLocked = false

    if state.story.isPhase(2) and state.story.flags.hasSmartphone then
        bedroomLocked = false
        bedroom2Locked = true
    end

    if state.story.isPhase(3) then
        bedroomLocked = true
        bedroom2Locked = false
        stairsLocked = true
        state.world["Lighting"].vignetteSize = 0.45
    end

    door.create(300, 305, "bedroom", bedroomLocked, {x=950,y=475})
    door.create(900, 305, "bedroom_2", bedroom2Locked, {x=100,y=475})

    painting.create(610, 325)

    staircase.create(-995, 107, "downstairs_hall", stairsLocked, {x=670,y=475}, true, true)

    if not state.story.isPhase(3) then
        vent.create(620, 550, "upstairs_hall", {x=800,y=475})
    end

    wall.create(-1000, -15)
    wall.create(1755, -17)
    floor.create(-1000, 625, 1500)
    window.create(-100, 275)
    window.create(1350, 275)

    if state.story.isPhase(2) and state.story.flags.hasSmartphone
        and not state.story.isAtLeastStep("going_upstairs") then
        state.story.setStep("going_upstairs")
    end
end

function level.update(dt)
end

function level.kill()
end

return level