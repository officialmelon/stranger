local world = require("game.systems.world")
local player = require("game.systems.player")
local utils = require("utils.utils")
local ui = require("ui.ui")
local worldspace = require("ui.worldspace")
local state = require("state.state")

local chest = require("game.objects.chest")
local door = require("game.objects.door")
local bed = require("game.objects.bed")
local window = require("game.objects.window")
local wall = require("game.objects.wall")
local dresser = require("game.objects.dresser")
local floor = require("game.objects.floor")
local painting = require("game.objects.painting")

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(0, 350)

    --// map creation

    dresser.create(300, 470, true)
    chest.create(550, 470)
    door.create(1000, 305, "level2")
    bed.create(1400, 500, true)
    wall.create(0, 0)
    wall.create(1850, 0)
    floor.create(0, 625, 1850)
    painting.create(600, 250)    
    window.create(1250, 350)
end

function level.update(dt)
    
end

function level.kill()
    
end

return level