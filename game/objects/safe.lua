--// Safe
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")
local Safe = {}

local img = utils.setup_img("assets/sprites/enviroment/safe/safe_unopen.png")
local img_open = utils.setup_img("assets/sprites/enviroment/safe/safe_open.png")

local sprites = {
    ["default"] = world.createObject(img),
    ["open"] = world.createObject(img_open)
}

function Safe.create(x, y) --// TODO implement hidden item logic
    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 1, 30)
    local centerX, centerY = utils.getObjectCenter(instance)
    local function onActivate()
        if state.player.equippedItem and state.player.equippedItem.name == "key" then
            state.player.equippedItem = nil
            state.player.inventory["key"] = false
            instance.obj = sprites["open"]
        else
            worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["SAFE_PROMPT"], 15, 2, onActivate, true)
        end
    end
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["SAFE_PROMPT"], 15, 2, onActivate, true)
end

return Safe