--// Smartphone
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")
local smartphone = {}
local img_open = utils.setup_img("assets/sprites/items/smartphone/smartphone.png")

local sprites = {
    ["default"]   = world.createObject(img_open),
}

function smartphone.create(x, y, storyOrDecoration)
    local stateKey = "item_smartphone_" .. x .. "_" .. y
    if world.getPersistentState(stateKey) == "collected" then
        return
    end
    
    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 0.25, 3, nil)

    local function onPickup()
        world.setPersistentState(stateKey, "collected")
        world.removeObjectFromEnviroment(instance)
        player.addToInventory("smartphone")

        if storyOrDecoration and state.story.isPhase(2) then
            state.story.flags.hasSmartphone = true
            state.story.setStep("found_smartphone")
            ui.displayText(
                utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["PHONE_POWERON"]),
                620,
                state.translations[state.translations.currentLanguage]["PHONE_POWERON"], 3.0,
                false)

            state.world.Camera.shake.intensity = 2
            state.world.Camera.shake.duration = 0.3

            local intruderSystem = require("game.systems.intruder")
            intruderSystem.alertToRoom(state.world["CurrentLevel"], state.player.x)
        else
            ui.displayText(
                utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"]),
                620,
                state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"], 2.5)
        end
    end

    local function onExamine()
        local centerX, centerY = utils.getObjectCenter(instance)
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["DIAL_911_SMARTPHONE"]),
            620,
            state.translations[state.translations.currentLanguage]["DIAL_911_SMARTPHONE"], 2.5,
            true
        )
        worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["PICKUP_SMARTPHONE"], 15, 2, onPickup, true)
    end

    if not storyOrDecoration then return end

    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["PICKUP_SMARTPHONE"], 15, 2, onPickup, true)
end

return smartphone