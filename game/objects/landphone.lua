--// Landline Phone
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local ui = require("ui.ui")
local state = require("state.state")
local Landline = {}

local img = utils.setup_img("assets/sprites/enviroment/landlinephone/landlinephone.png")

local sprites = {
    ["Landline"]   = world.createObject(img)
}

function Landline.create(x, y)
    local instance = world.insertObjectIntoEnviroment(sprites["Landline"], x, y, 1, 3)

    if state.story.isPast(1) then
        local centerX, centerY = utils.getObjectCenter(instance)
        worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["LANDLINE_PROMPT"], 15, 2, function()
            ui.displayText(
                utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["LANDLINE_CUT"]),
                620,
                state.translations[state.translations.currentLanguage]["LANDLINE_CUT"], 3.0,
                false)
            state.story.flags.landlineUsed = true
            state.story.setStep("found_phone")
        end, true)
    end
end

return Landline
