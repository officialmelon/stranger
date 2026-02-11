--// Screwdriver
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")
local Screwdriver = {}
local img_open = utils.setup_img("assets/sprites/items/screwdriver/screwdriver.png")

local sprites = {
    ["default"]   = world.createObject(img_open),
}

function Screwdriver.create(x, y, story)
    local stateKey = "item_screwdriver_" .. x .. "_" .. y
    if world.getPersistentState(stateKey) == "collected" then
        return
    end
    
    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 1.25, 3, nil)

    local function onInteract()
        if story then
            state.story.flags.hasScrewdriver = true
            state.story.setStep("found_screwdriver")
        end
        world.setPersistentState(stateKey, "collected")
        world.removeObjectFromEnviroment(instance)
        text = ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"]),
            love.graphics.getHeight() - 100,
            state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"], 2.5)

        player.addToInventory("screwdriver")
    end
    
    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["PICKUP_SCREWDRIVER"], 15, 2, onInteract, true)
end

return Screwdriver