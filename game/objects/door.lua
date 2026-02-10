--// Door
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local gameplay = require("game.scenes.gameplay")
local fade = require("ui.fade")
local UI = require("ui.ui")
local state = require("state.state")
local intruderSystem = require("game.systems.intruder")

local Door = {}

local img_closed = utils.setup_img("assets/sprites/enviroment/door/door_closed.png")
local img_arch = utils.setup_img("assets/sprites/enviroment/door/door_arch.png")

local sprites = {
    ["closed"] = world.createObject(img_closed),
    ["arch"] = world.createObject(img_arch)
}

function Door.create(x, y, level_name, locked, x_y_spawn, archway)
    local currentRoom = state.world["CurrentLevel"]
    if currentRoom then
        intruderSystem.registerDoor(currentRoom, level_name, x, x_y_spawn)
        intruderSystem.registerDoor(level_name, currentRoom, x_y_spawn.x, {x = x, y = x_y_spawn.y})
    end
    local instance = world.insertObjectIntoEnviroment(archway and sprites["arch"] or sprites["closed"], x, y, 2.5, 3)

    local function onInteract()
        if locked then
            local c = UI.displayText(utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["DOOR_LOCKED"]), 720 - 100, state.translations[state.translations.currentLanguage]["DOOR_LOCKED"], 2.5)
            return
        end

        player.setState("isHiding", true)
        state.world["CurrentLevel"] = level_name

        print("door")

        fade.Out(function ()
            gameplay.loadLevel(level_name)
            player.goTo(x_y_spawn.x, x_y_spawn.y)
            fade.In()
            player.setState("isHiding", false)
        end)
    end

    worldspace.create_interact_worldspace_ui(x + ((archway and 150) or 75), y + 150, state.translations[state.translations.currentLanguage]["DOOR_PROMPT"], 15, 2, onInteract, true)
end

return Door