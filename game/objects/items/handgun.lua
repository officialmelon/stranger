--// Handgun
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")
local Handgun = {}

local img = utils.setup_img("assets/sprites/items/handgun/handgun.png")

local sprites = {
    ["default"] = world.createObject(img),
}

function Handgun.create(x, y)
    local stateKey = "item_handgun_" .. x .. "_" .. y
    if world.getPersistentState(stateKey) == "collected" then
        return
    end

    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 0.75, 5)

    local function onPickup()
        world.setPersistentState(stateKey, "collected")
        world.removeObjectFromEnviroment(instance)
        ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["FOUND_HANDGUN"]),
            620,
            state.translations[state.translations.currentLanguage]["FOUND_HANDGUN"], 3.0,
            false)
        player.addToInventory("handgun")
        state.story.flags.hasHandgun = true
    end

    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["PICKUP_HANDGUN"], 15, 2, onPickup, true)
end

return Handgun
