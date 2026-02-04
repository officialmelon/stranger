--// Cabinet
local utils = require("utils.utils")
local world = require("game.systems.world")
local Cabinet = {}

local default = utils.setup_img("assets/sprites/enviroment/cabinet/default.png")
local oven = utils.setup_img("assets/sprites/enviroment/cabinet/oven.png")
local pully = utils.setup_img("assets/sprites/enviroment/cabinet/pully.png")
local sink = utils.setup_img("assets/sprites/enviroment/cabinet/sink.png")

local sprites = {
    ["default"]   = world.createObject(default),
    ["oven"] = world.createObject(oven),
    ["pully"] = world.createObject(pully),
    ["sink"] = world.createObject(sink)
}

function Cabinet.create(x, y, name)
    local offset = 0
    if sprites[name or "default"].image:getHeight() > 225 then
        offset = (sprites[name or "default"].image:getHeight() - 225)
    end
    local instance = world.insertObjectIntoEnviroment(sprites[name or "default"], x, y - (offset * 0.5), 0.6, 0.75)
end

return Cabinet