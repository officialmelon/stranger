local utils = require("utils.utils")
local world = require("game.systems.world")
local Mug = {}

local state = require("state.state")
local ui = require("ui.ui")
local worldspace = require("ui.worldspace")
local default = utils.setup_img("assets/sprites/items/mug/mug.png")
local player = require("game.systems.player")

local sprites = {
    ["default"]   = world.createObject(default),
}

function Mug.create(x, y, storyOrDecoration) -- true if story, false if not.
    local stateKey = "item_mug_" .. x .. "_" .. y
    if world.getPersistentState(stateKey) == "collected" then
        return
    end

    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 1.5, 5)
    
    local function onPickup()
        world.setPersistentState(stateKey, "collected")
        world.removeObjectFromEnviroment(instance)
        text = ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"]),
            love.graphics.getHeight() - 100,
            state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"], 2.5)
        player.addToInventory("mug")
    end

    local function onExamine()
        local centerX, centerY = utils.getObjectCenter(instance)
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["EXAMINE_MUG"]),
            love.graphics.getHeight() - 100,
            state.translations[state.translations.currentLanguage]["EXAMINE_MUG"], 2.5,
            true)
        worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["PICKUP_MUG"], 15, 2, onPickup, true)
    end

    if not storyOrDecoration then return end

    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["EXAMINE_MUG_PROMPT"], 15, 2, onExamine, true)
end

return Mug