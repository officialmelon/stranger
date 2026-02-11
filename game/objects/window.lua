--// Window
local utils = require("utils.utils")
local world = require("game.systems.world")
local peachy = require("libraries.peachy")
local state = require("state.state")

local Window = {}
local image_data = utils.setup_img("assets/sprites/enviroment/window/boarded_night.png")
local image_data_1 =utils.setup_img("assets/sprites/enviroment/window/window_noboards.png")

local animated_window = peachy.new("assets/sprites/enviroment/window/boarded_night.json", image_data, "Raining")
local animated_window_noboards = peachy.new("assets/sprites/enviroment/window/window_noboards.json", image_data_1, "Raining")

local sprites = {
    ["animated"] = world.createObject(animated_window),
    ["noboards"] = world.createObject(animated_window_noboards)
}

state.world.windows = state.world.windows or {}

function Window.create(x, y)
    local chosenWindow = state.story.isPast(1) and sprites["animated"] or sprites["noboards"]
    local inst = world.insertObjectIntoEnviroment(chosenWindow, x, y, 1, -1, nil)

    table.insert(state.world.windows, { x = x, y = y })
end
return Window