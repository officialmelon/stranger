local utils = require("utils.utils")
local world = require("game.systems.world")
local Torch = {}

local state = require("state.state")
local ui = require("ui.ui")
local worldspace = require("ui.worldspace")
local default = utils.setup_img("assets/sprites/items/torch/torch.png")
local player = require("game.systems.player")

local sprites = {
    ["default"]   = world.createObject(default),
}

function Torch.create(x, y)
    local stateKey = "item_torch_" .. x .. "_" .. y
    if world.getPersistentState(stateKey) == "collected" then
        return
    end

    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 1.25, 5)
    
    local function onPickup()
        world.setPersistentState(stateKey, "collected")
        world.removeObjectFromEnviroment(instance)
        text = ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"]),
            love.graphics.getHeight() - 100,
            state.translations[state.translations.currentLanguage]["ITEM_PICKED_UP"])
        player.addToInventory("torch")
    end
    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["PICKUP_FLASHLIGHT"], 15, 2, onPickup, true)
end

function Torch.use()
    if state.world.Lighting.vignetteSize == 0.5 then
        state.world.Lighting.vignetteSize = state.world.Lighting.defaultVignetteSize
    else
        state.world.Lighting.vignetteSize = 0.5
    end
end

return Torch