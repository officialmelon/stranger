--// Crt
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local state = require("state.state")

local Crt = {}

local img = utils.setup_img("assets/sprites/enviroment/crt/crt_behind.png")
local img2 = utils.setup_img("assets/sprites/enviroment/crt/crt_off_front.png")
local img3 = utils.setup_img("assets/sprites/enviroment/crt/crt_on.png")

local sprites = {
    ["behind"]   = world.createObject(img),
    ["crt_off"] = world.createObject(img2),
    ["crt_on"] = world.createObject(img3)
}

function Crt.create(x, y, type)
    local instance = world.insertObjectIntoEnviroment(sprites[type] or sprites["crt_off"], x, y, 1, 3)

    local function onActivate() --// TODO: Implement noise to point logic.
        instance.obj = sprites["crt_on"]
    end

    if instance.obj == sprites["behind"] then --// no sprite/system for that.
        return
    end

    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, state.translations[state.translations.currentLanguage]["MAKE_NOISE_PROMPT"], 30, 0.75, onActivate, true)
end

return Crt