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
    
    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 0.25, 3, nil)

    local function onPickup()
        world.removeObjectFromEnviroment(instance)
        text = ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"]),
            love.graphics.getHeight() - 100,
            state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"], 2.5)
        player.addToInventory("smartphone")
    end

    local function onExamine()
        local centerX, centerY = utils.getObjectCenter(instance)
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["DIAL_911_SMARTPHONE"]),
            love.graphics.getHeight() - 100,
            state.translations[state.translations.currentLanguage]["DIAL_911_SMARTPHONE"], 2.5,
            true
        )
        worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["PICKUP_SMARTPHONE"], 15, 2, onPickup, true)
    end

    if not storyOrDecoration then return end

    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["DIAL_911_SMARTPHONE_PROMPT"], 15, 2, onExamine, true)
end

return smartphone