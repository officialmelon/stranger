--// Shower
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local intruder = require("game.systems.intruder")
local ui = require("ui.ui")
local state = require("state.state")
local Shower = {}

local img_open = utils.setup_img("assets/sprites/enviroment/shower/shower.png")
local img_closed = utils.setup_img("assets/sprites/enviroment/shower/shower_hiding.png")

local sprites = {
    ["default"]   = world.createObject(img_open),
    ["hiding"] = world.createObject(img_closed)
}

function Shower.create(x, y)
    local isHidingInside = false

    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 1.5, 3)
    local text
    
    local function onInteract()
        if isHidingInside then
            return
        end

        intruder.onPlayerHide()

        text = ui.displayText(
            utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["EXIT_HIDING"]),
            720 - 100,
            state.translations[state.translations.currentLanguage]["EXIT_HIDING"])
        state.world["Lighting"].vignetteSize = state.world["Lighting"].hideVignetteSize
        player.setState("isHiding", true)
        print("hiding")
        isHidingInside = true 
        
        instance.obj = sprites["hiding"]
        state.player.currentHidingSpot = {
            exit = function ()
                state.world["Lighting"].vignetteSize = 1
                player.setState("isHiding", false)
                isHidingInside = false
                instance.obj = sprites["default"]
                text.remove()
                local centerX, centerY = utils.getObjectCenter(instance)
                local offsetX = flipped and 200 or -200
            end
        }
    end
    
    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY + 50, state.translations[state.translations.currentLanguage]["HIDE_PROMPT"], 30, 0.75, onInteract, false)
end

return Shower