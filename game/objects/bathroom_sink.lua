--// Sink
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local state = require("state.state")
local peachy= require("libraries.peachy")

local intruder = require("game.systems.intruder")

local Sink = {}

local img = utils.setup_img("assets/sprites/enviroment/sink/sink_off.png")
local img2 = utils.setup_img("assets/sprites/enviroment/Sink/sink_on.png")

local sprites = {
    ["Sink_off"] = world.createObject(img),
    ["Sink_on"] = world.createObject(peachy.new("assets/sprites/enviroment/sink/sink_on.json", img2, "On"))
}

function Sink.create(x, y, type, currentLevel)
    local stateKey = "Sink_" .. x .. "_" .. y
    local savedType = world.getPersistentState(stateKey)
    local activeType = savedType or type

    local instance = world.insertObjectIntoEnviroment(sprites[activeType] or sprites["Sink_off"], x, y, 1.25, 3)

    local function onActivate()
        instance.obj = sprites["Sink_on"]
        world.setPersistentState(stateKey, "Sink_on")
        intruder.gotoPoint(currentLevel, x)
    end

    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["MAKE_NOISE_PROMPT"], 200, 0.75, onActivate, true)
end

return Sink