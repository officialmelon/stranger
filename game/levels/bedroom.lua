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
local cabinet = require("game.objects.cabinet")
local vent = require("game.objects.vent")

local polaroid = require("game.objects.items.polaroid")
local smartphone = require("game.objects.items.smartphone")
local screwdriver = require("game.objects.items.screwdriver")
local torch = require("game.objects.items.torch")
local key = require("game.objects.items.key")

local safe = require("game.objects.safe")

local level = {}

function level.load()
    world.clear()

    state.world["Lighting"].vignetteSize = state.world["Lighting"].defaultVignetteSize

    player.goTo(15, 475)

    --// map creation

    screwdriver.create(445, 450)
    polaroid.create(525, 450)
    torch.create(600, 450)
    key.create(675, 450)


    dresser.create(445, 470, true)
    door.create(1000, 305, "hall", true, {x=1500,y=475})
    vent.create(835, 545, "hall", {x=1750,y=475}, 1)
    bed.create(5, 500, false, true)
    wall.create(0, -15)
    wall.create(1175, -17)
    floor.create(0, 625, 1000)
    window.create(550, 275)
end

function level.update(dt)
    
end

function level.kill()
    
end

return level