--// Door
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local gameplay = require("game.scenes.gameplay")
local fade = require("ui.fade")
local UI = require("ui.ui")

local Door = {}

local img_closed = utils.setup_img("assets/sprites/enviroment/door/door_closed.png")

local sprites = {
    ["closed"] = world.createObject(img_closed)
}

local lockedtxt = "Door locked."

function Door.create(x, y, level_name, locked)
    local instance = world.insertObjectIntoEnviroment(sprites["closed"], x, y, 2.5, 3)

    local function onInteract()
        if locked then
            local c = UI.displayText(640, 620, lockedtxt)
            utils.delay(3, function ()
                c.remove()
            end)
            return
        end

        player.setState("isHiding", true)

        print("door")

        fade.Out(function ()
            gameplay.loadLevel(level_name)
            fade.In()
            player.setState("isHiding", false)
        end)
    end

    worldspace.create_interact_worldspace_ui(x + 75, y + 150, "Enter Room", 15, 2, onInteract)
end

return Door