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

function Key.create(x, y)
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
            love.graphics.getHeight() - 100,
            state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"])
        player.addToInventory("key")
    end
    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["PICKUP_KEY"], 15, 2, onPickup, true)
end

return Key