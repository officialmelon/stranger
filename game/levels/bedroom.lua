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

local phase3Timer = 0
local phase3Stage = 0

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    local enteringPhase3 = false
    if state.story.isPhase(2) and state.story.isStep("going_upstairs") then
        local intruderSystem = require("game.systems.intruder")
        intruderSystem.deactivate()
        state.story.advancePhase()
        enteringPhase3 = true
    end

    player.goTo(15, 475)

    local doorLocked = not state.story.isPhase(1)
    if state.story.isPhase(3) then
        doorLocked = true
    end
    if state.story.isPhase(3) and state.story.isAtLeastStep("vent_banging") then
        doorLocked = false
    end

    door.create(950, 310, "upstairs_hall", doorLocked, {x=300,y=475})

    if not state.story.isPhase(3) then
        vent.create(800, 550, "upstairs_hall", {x=625,y=475}, 67)
    end

    wall.create(0, -15)
    wall.create(1180, -17)
    floor.create(0, 625, 900)

    bed.create(5, 500, false, true)
    dresser.create(425, 475, false)

    if state.story.isPhase(2) then
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

    if state.story.isPhase(3) then
        state.world["Lighting"].vignetteSize = 0.55

        if enteringPhase3 then
            fade.In(1.5)
            state.story.refreshTask()
            ui.displayText(
                utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["DOOR_LOCKED_SAFE"]),
                620,
                state.translations[state.translations.currentLanguage]["DOOR_LOCKED_SAFE"], 3.5,
                false)
        end

        if not state.story.flags.phoneDead then
            phase3Timer = 0
            phase3Stage = 0
            level.createPhonePrompt()
        elseif state.story.isAtLeastStep("vent_banging") then
            phase3Timer = 0
            phase3Stage = 99
        end
    end
end

function level.createPhonePrompt()
    worldspace.create_interact_worldspace_ui(200, 450, state.translations[state.translations.currentLanguage]["CALL_911"], 40, 2, function()
        state.story.setStep("call_police")
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["CALLING_911"]),
            620,
            state.translations[state.translations.currentLanguage]["CALLING_911"], 3.0,
            false)
        phase3Timer = 0
        phase3Stage = 1
    end, true)
end

function level.update(dt)
    if not state.story.isPhase(3) then return end
    if phase3Stage == 0 then return end

    phase3Timer = phase3Timer + dt

    if phase3Stage == 1 and phase3Timer > 4.5 then
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["PARTIAL_ADDRESS"]),
            620,
            state.translations[state.translations.currentLanguage]["PARTIAL_ADDRESS"], 3.0,
            false)
        phase3Stage = 2
        phase3Timer = 0

    elseif phase3Stage == 2 and phase3Timer > 4.5 then
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["PHONE_DIED"]),
            620,
            state.translations[state.translations.currentLanguage]["PHONE_DIED"], 3.0,
            false)
        state.story.flags.phoneDead = true
        state.story.setStep("phone_dead")
        phase3Stage = 3
        phase3Timer = 0

    elseif phase3Stage == 3 and phase3Timer > 4.0 then
        state.world.Camera.shake.intensity = 4
        state.world.Camera.shake.duration = 4.0
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["DOOR_BANGING"]),
            620,
            state.translations[state.translations.currentLanguage]["DOOR_BANGING"], 2.5,
            false)
        phase3Stage = 4
        phase3Timer = 0

    elseif phase3Stage == 4 and phase3Timer > 5.0 then
        state.world.Camera.shake.intensity = 0
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["BANGING_STOPPED"]),
            620,
            state.translations[state.translations.currentLanguage]["BANGING_STOPPED"], 3.0,
            false)
        state.story.setStep("banging_stops")
        phase3Stage = 5
        phase3Timer = 0

    elseif phase3Stage == 5 and phase3Timer > 5.0 then
        state.world.Camera.shake.intensity = 2
        state.world.Camera.shake.duration = 2.0
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["VENT_BANGING"]),
            620,
            state.translations[state.translations.currentLanguage]["VENT_BANGING"], 3.5,
            false)
        state.story.setStep("vent_banging")
        phase3Stage = 6
        phase3Timer = 0

    elseif phase3Stage == 6 and phase3Timer > 4.5 then
        state.world.Camera.shake.intensity = 0
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["ESCAPE_NOW"]),
            620,
            state.translations[state.translations.currentLanguage]["ESCAPE_NOW"], 3.0,
            false)

        local gameplay = require("game.scenes.gameplay")
        gameplay.loadLevel("bedroom")
        player.goTo(15, 475)
        phase3Stage = 99
    end
end

function level.kill()
    phase3Timer = 0
    phase3Stage = 0
end

return level