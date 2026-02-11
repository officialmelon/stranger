local world = require("game.systems.world")
local player = require("game.systems.player")
local utils = require("utils.utils")
local ui = require("ui.ui")
local worldspace = require("ui.worldspace")
local state = require("state.state")
local fade = require("ui.fade")
local sounds = require("game.systems.sound")

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

local mug = require("game.objects.items.mug")

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(15, 475)

    local doorLocked = not state.story.isPhase(1)

    door.create(950, 310, "upstairs_hall", doorLocked, {x=300,y=475})

    vent.create(800, 550, "upstairs_hall", {x=625,y=475}, 67)

    wall.create(0, -15)
    wall.create(1180, -17)
    floor.create(0, 625, 900)

    bed.create(5, 500, false, true)
    dresser.create(425, 475, false)

    if state.story.isPast(1) then
        screwdriver.create(475, 460, true)
    end

    if state.story.isPhase(1) and state.story.isStep("wake_up") then
        fade.In(2.5)
        state.story.setStep("heard_noise")
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["NOISE_INVESTIGATE"]),
            love.graphics.getHeight() - 100,
            state.translations[state.translations.currentLanguage]["NOISE_INVESTIGATE"], 3.0,
            false)
    end
end

function level.update(dt)
    
end

function level.kill()
    
end

return level