--// Crt
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local state = require("state.state")

local intruder = require("game.systems.intruder")

local Crt = {}

local img = utils.setup_img("assets/sprites/enviroment/crt/crt_behind.png")
local img2 = utils.setup_img("assets/sprites/enviroment/crt/crt_off_front.png")
local img3 = utils.setup_img("assets/sprites/enviroment/crt/crt_on.png")

local sprites = {
    ["behind"]   = world.createObject(img),
    ["crt_off"] = world.createObject(img2),
    ["crt_on"] = world.createObject(img3)
}

function Crt.create(x, y, type, currentLevel)
    local stateKey = "crt_" .. x .. "_" .. y
    local savedType = world.getPersistentState(stateKey)
    local activeType = savedType or type

    local instance = world.insertObjectIntoEnviroment(sprites[activeType] or sprites["crt_off"], x, y, 1, 3)

    local function onActivate()
        instance.obj = sprites["crt_on"]
        world.setPersistentState(stateKey, "crt_on")
        intruder.gotoPoint(currentLevel, x)
    end

    if instance.obj == sprites["behind"] then --// no sprite/system for that.
        return
    end

    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["MAKE_NOISE_PROMPT"], 200, 0.75, onActivate, true)
end

return Crt