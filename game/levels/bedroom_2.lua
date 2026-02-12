local world = require("game.systems.world")
local player = require("game.systems.player")
local utils = require("utils.utils")
local ui = require("ui.ui")
local worldspace = require("ui.worldspace")
local state = require("state.state")
local fade = require("ui.fade")
local crt   = require("game.objects.crt")
local blood = require("game.objects.blood")
local intruderSystem = require("game.systems.intruder")

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
local handgun = require("game.objects.items.handgun")

local mug = require("game.objects.items.mug")

local level = {}

local endingTimer = 0
local endingStage = 0
local shotCount = 0
local confrontPrompt = nil

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(15, 475)

    door.create(100, 310, "upstairs_hall", false, {x=900,y=475})

    wall.create(0, -15)
    wall.create(1575, -17)
    floor.create(0, 625, 1500)

    bed.create(1185, 500, true)
    dresser.create(750, 475, true)
    window.create(1325, 275)
    crt.create(935, 335, true)
    plants.create(800, 352)
    painting.create(450,275)

    blood.create(135, 400)

    if state.story.isPhase(3) and state.story.isAtLeastStep("vent_banging") then
        state.world["Lighting"].vignetteSize = 0.4

        intruderSystem.deactivate()

        handgun.create(790, 455)

        state.story.setStep("ending")

        endingTimer = 0
        endingStage = 1
        shotCount = 0
        confrontPrompt = nil
    end
end

function level.update(dt)
    if not state.story.isPhase(3) then return end
    if endingStage == 0 then return end

    endingTimer = endingTimer + dt

    if endingStage == 1 and endingTimer > 8.0 then
        state.player.isAbleToMove = false

        intruderSystem.activate()
        intruderSystem.setRoom("bedroom_2")
        intruderSystem.setPosition(100, 475)
        state.intruder.currentState = "IDLE"

        state.world.Camera.shake.intensity = 4
        state.world.Camera.shake.duration = 1.5

        if state.story.flags.hasHandgun then
            endingStage = 10
        else
            endingStage = 20
        end
        endingTimer = 0
    end

    if endingStage == 10 then
        confrontPrompt = worldspace.create_interact_worldspace_ui(
            state.player.x, state.player.y - 60,
            state.translations[state.translations.currentLanguage]["CONFRONT_INTRUDER"],
            50, 0.3,
            function()
                shotCount = shotCount + 1
                state.world.Camera.shake.intensity = 6
                state.world.Camera.shake.duration = 0.4

                ui.displayText(
                    utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["GOOD_ENDING_SHOT"]),
                    620,
                    state.translations[state.translations.currentLanguage]["GOOD_ENDING_SHOT"], 0.6,
                    false)

                if shotCount >= 3 then
                    if confrontPrompt then
                        worldspace.remove_interact_worldspace_ui(confrontPrompt)
                        confrontPrompt = nil
                    end
                    intruderSystem.deactivate()
                    endingStage = 11
                    endingTimer = 0
                end
            end,
            false
        )
        endingStage = 100

    elseif endingStage == 11 and endingTimer > 2.5 then
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["SIRENS"]),
            620,
            state.translations[state.translations.currentLanguage]["SIRENS"], 4.0,
            false)
        endingStage = 12
        endingTimer = 0

    elseif endingStage == 12 and endingTimer > 5.0 then
        fade.Out(function() end, 3.0)
        endingStage = 99

    elseif endingStage == 20 then
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["BAD_ENDING"]),
            620,
            state.translations[state.translations.currentLanguage]["BAD_ENDING"], 3.0,
            false)
        endingStage = 21
        endingTimer = 0

    elseif endingStage == 21 and endingTimer > 3.5 then
        fade.Out(function() end, 3.0)
        endingStage = 99
    end
end

function level.kill()
    endingTimer = 0
    endingStage = 0
    shotCount = 0
    confrontPrompt = nil
end

return level