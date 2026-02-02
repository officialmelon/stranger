--// Door
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local state = require("state.state")
local gameplay = require("game.scenes.gameplay")
local fade = require("ui.fade")
local UI = require("ui.ui")

local Door = {}

local img_vent = utils.setup_img("assets/sprites/enviroment/vent/vent.png")

local sprites = {
    ["vent"] = world.createObject(img_vent)
}

local noScrewdriver = "Screwed shut... Maybe there is another way to open this?"

function Door.create(x, y, level_name, x_y_spawn)
    local instance = world.insertObjectIntoEnviroment(sprites["vent"], x, y, 1, 0)

    local function onInteract()
        if not state.player.equippedItem or state.player.equippedItem.name ~= "screwdriver" then
            local c = UI.displayText(640, 620, noScrewdriver)
            utils.delay(3, function ()
                c.remove()
            end)
            return
        end

        player.setState("isHiding", true)

        print("vent")

        fade.Out(function ()
            gameplay.loadLevel(level_name)
            player.goTo(x_y_spawn.x, x_y_spawn.y)
            fade.In()
            player.setState("isHiding", false)
        end)
    end

    worldspace.create_interact_worldspace_ui(x + 62.5, y - 37.5, "Crawl through", 15, 2, onInteract, false)
end

return Door