--// Door
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local state = require("state.state")
local gameplay = require("game.scenes.gameplay")
local fade = require("ui.fade")
local UI = require("ui.ui")
local sound = require("game.systems.sound")

local Door = {}

local img_vent = utils.setup_img("assets/sprites/enviroment/vent/vent.png")
local img_open = utils.setup_img("assets/sprites/enviroment/vent/vent_open.png")

local sprites = {
    ["vent"] = world.createObject(img_vent),
    ["open"] = world.createObject(img_open)
}

local vents = {}


function Door.create(x, y, level_name, x_y_spawn, id, callback)
    local instance = world.insertObjectIntoEnviroment(sprites["vent"], x, y, 1, 5)
    local worldspace_ui = nil

    local function goThroughVent()
        player.setState("isHiding", true)
        print("vent")

        if state.story.isPhase(2) and not state.story.flags.ventOpened then
            state.story.flags.ventOpened = true
            state.story.setStep("in_hall")
        end

        fade.Out(function ()
            gameplay.loadLevel(level_name)
            player.goTo(x_y_spawn.x, x_y_spawn.y)
            fade.In()
            player.setState("isHiding", false)
        end)
    end

    local function onInteract()
        if not state.player.equippedItem or state.player.equippedItem.name ~= "screwdriver" then
            local c = UI.displayText(utils.returnTextCenteredWidth(state.translations[state.translations.currentLanguage]["CANT_OPEN_VENT"]), 620, state.translations[state.translations.currentLanguage]["CANT_OPEN_VENT"], 2.5)
            return
        end

        if callback then
            local tsk = UI.addTask(state.translations[state.translations.currentLanguage]["BEDROOM_INVESTIGATE"])
            state.player.currentTask = tsk
        end

        worldspace.remove_interact_worldspace_ui(worldspace_ui)

        sound.play("vent_open")

        instance.obj = sprites["open"]
        worldspace.create_interact_worldspace_ui(x + 62.5, y - 37.5, state.translations[state.translations.currentLanguage]["VENT_PROMPT"], 15, 2, goThroughVent, false)
        
        for _, vent in ipairs(vents) do
            if vent.id == id then
                vent.open = true
            end
        end
    end

    local isOpen = false
    for _, vent in ipairs(vents) do
        if vent.id == id and vent.open then
            isOpen = true
            break
        end
    end

    if isOpen then
        instance.obj = sprites["open"]
        worldspace_ui = worldspace.create_interact_worldspace_ui(x + 62.5, y - 37.5, state.translations[state.translations.currentLanguage]["VENT_PROMPT"], 15, 2, goThroughVent, false)
    else
        table.insert(vents, {inst=instance, id=id, open=false})
        worldspace_ui = worldspace.create_interact_worldspace_ui(x + 62.5, y - 37.5, state.translations[state.translations.currentLanguage]["VENT_UNSCREW_PROMPT"], 15, 2, onInteract, false)
    end
end

return Door