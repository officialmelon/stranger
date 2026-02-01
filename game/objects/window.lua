--// Window
local utils = require("utils.utils")
local world = require("game.systems.world")

local Window = {}

local boarded_night = utils.setup_img("assets/sprites/enviroment/window/boarded_night.png")

local sprites = {
    ["boarded_night"]   = world.createObject(boarded_night),
}

function Window.create(x, y)

    world.insertObjectIntoEnviroment(sprites["boarded_night"], x, y, 1, 3, nil)

end

return Window