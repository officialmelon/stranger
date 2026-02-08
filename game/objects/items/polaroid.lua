local utils = require("utils.utils")
local world = require("game.systems.world")
local effects = require("game.systems.effects")
local intruder = require("game.systems.intruder")
local Polaroid = {}

local lastUseTime = -45
local cooldown = 45


local state = require("state.state")
local ui = require("ui.ui")
local worldspace = require("ui.worldspace")
local default = utils.setup_img("assets/sprites/items/polaroid/polaroid.png")
local player = require("game.systems.player")

local sprites = {
    ["default"]   = world.createObject(default),
}

function Polaroid.create(x, y)
    local stateKey = "item_polaroid_" .. x .. "_" .. y
    if world.getPersistentState(stateKey) == "collected" then
        return
    end

    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 0.4, 5)
    
    local function onPickup()
        world.setPersistentState(stateKey, "collected")
        world.removeObjectFromEnviroment(instance)
        text = ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"]),
            love.graphics.getHeight() - 100,
            state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"])
        player.addToInventory("polaroid")
    end
    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["PICKUP_POLAROID"], 15, 2, onPickup, true)
end

function Polaroid.use()
    local currentTime = love.timer.getTime()
    if currentTime - lastUseTime >= cooldown then
        effects.effect_table.flash.intensity = 1
        intruder.stun(8)
        lastUseTime = currentTime
    end
end

return Polaroid