--// Staircase
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local gameplay = require("game.scenes.gameplay")
local fade = require("ui.fade")
local UI = require("ui.ui")
local state = require("state.state")
local intruderSystem = require("game.systems.intruder")
local Staircase = {}

local img = utils.setup_img("assets/sprites/enviroment/staircase/staircase.png")

local sprites = {
    ["stairs"]   = world.createObject(img),
}

function Staircase.create(x, y, level_name, locked, x_y_spawn)
    local instance = world.insertObjectIntoEnviroment(sprites["stairs"], x, y, 0.9, 3)
    local currentRoom = state.world["CurrentLevel"]
    if currentRoom then
        intruderSystem.registerDoor(currentRoom, level_name, x, x_y_spawn)
    end

    local function onInteract()
        if locked then
            local c = UI.displayText(utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["STAIRS_PROMPT"]), 720 - 100, state.translations[state.translations.currentLanguage]["DOOR_LOCKED"], 2.5)
            return
        end

        player.setState("isHiding", true)

        fade.Out(function ()
            gameplay.loadLevel(level_name)
            player.goTo(x_y_spawn.x, x_y_spawn.y)
            fade.In()
            player.setState("isHiding", false)
        end)
    end

    worldspace.create_interact_worldspace_ui(x, y + 300, state.translations[state.translations.currentLanguage]["STAIRS_PROMPT"], 35, 2, onInteract, true)
end

return Staircase