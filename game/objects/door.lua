--// Door
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local gameplay = require("game.scenes.gameplay")
local fade = require("ui.fade")
local UI = require("ui.ui")
local state = require("state.state")

local Door = {}

local img_closed = utils.setup_img("assets/sprites/enviroment/door/door_closed.png")

local sprites = {
    ["closed"] = world.createObject(img_closed)
}

function Door.create(x, y, level_name, locked, x_y_spawn)
    local instance = world.insertObjectIntoEnviroment(sprites["closed"], x, y, 2.5, 3)

    local function onInteract()
        if locked then
            local c = UI.displayText(utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["DOOR_LOCKED"]), 720 - 100, state.translations[state.translations.currentLanguage]["DOOR_LOCKED"], 2.5)
            return
        end

        player.setState("isHiding", true)

        print("door")

        fade.Out(function ()
            gameplay.loadLevel(level_name)
            player.goTo(x_y_spawn.x, x_y_spawn.y)
            fade.In()
            player.setState("isHiding", false)
        end)
    end

    worldspace.create_interact_worldspace_ui(x + 75, y + 150, state.translations[state.translations.currentLanguage]["DOOR_PROMPT"], 15, 2, onInteract, true)
end

return Door