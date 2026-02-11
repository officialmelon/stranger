local utils = require("utils.utils")
local world = require("game.systems.world")
local Key = {}

local state = require("state.state")
local ui = require("ui.ui")
local worldspace = require("ui.worldspace")
local default = utils.setup_img("assets/sprites/items/key/key.png")
local player = require("game.systems.player")

local sprites = {
    ["default"]   = world.createObject(default),
}

function Key.create(x, y, story)
    local stateKey = "item_key_" .. x .. "_" .. y
    if world.getPersistentState(stateKey) == "collected" then
        return
    end

    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 0.75, 5)
    
    local function onPickup()
        world.setPersistentState(stateKey, "collected")
        world.removeObjectFromEnviroment(instance)
        text = ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"]),
            620,
            state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"], 2.5)
        player.addToInventory("key")

        if story and state.story.isPhase(2) then
            state.story.flags.hasKey = true
            state.story.setStep("found_key")
        end
    end
    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["PICKUP_KEY"], 15, 2, onPickup, true)
end

return Key