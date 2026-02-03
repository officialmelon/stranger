--// Window
local utils = require("utils.utils")
local world = require("game.systems.world")
local peachy = require("libraries.peachy")
local state = require("state.state")

local Window = {}
local image_data = love.graphics.newImage("assets/sprites/enviroment/window/boarded_night.png")
local animated_window = peachy.new("assets/sprites/enviroment/window/boarded_night.json", image_data, "Raining")
local sprites = {
    ["animated"] = world.createObject(animated_window, true),
}

state.world.windows = state.world.windows or {}

function Window.create(x, y)
    world.insertObjectIntoEnviroment(sprites["animated"], x, y, 1, 3, nil)
    table.insert(state.world.windows, { x = x, y = y })
end
return Window