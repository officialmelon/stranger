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

function Safe.create(x, y, containedItem, spawnArgs, onOpen)
    local stateKey = "safe_" .. x .. "_" .. y
    local alreadyOpen = world.getPersistentState(stateKey) == "opened"

    local instance = world.insertObjectIntoEnviroment(
        alreadyOpen and sprites["open"] or sprites["default"], x, y, 1, 30
    )

    if alreadyOpen then
        if containedItem then
            local itemX = x + 30
            local itemY = y + 20
            containedItem.create(itemX, itemY, unpack(spawnArgs or {}))
        end
        return
    end

    local centerX, centerY = utils.getObjectCenter(instance)

    local function onActivate()
        if state.player.equippedItem and state.player.equippedItem.name == "key" then
            state.player.equippedItem = nil
            state.player.inventory["key"] = false
            instance.obj = sprites["open"]
            world.setPersistentState(stateKey, "opened")

            ui.displayText(
                utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["SAFE_OPENED"]),
                620,
                state.translations[state.translations.currentLanguage]["SAFE_OPENED"], 2.5,
                false)

            if containedItem then
                local itemX = x + 75
                local itemY = y + 75
                containedItem.create(itemX, itemY, unpack(spawnArgs or {}))
            end

            if onOpen then
                onOpen()
            end
        else
            worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["SAFE_PROMPT"], 15, 2, onActivate, true)
        end
    end

    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["SAFE_PROMPT"], 15, 2, onActivate, true)
end

return Safe