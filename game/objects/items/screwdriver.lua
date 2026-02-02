--// Screwdriver
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")
local Screwdriver = {}
local img_open = utils.setup_img("assets/sprites/items/screwdriver/screwdriver.png")

local sprites = {
    ["default"]   = world.createObject(img_open),
}

function Screwdriver.create(x, y)
    
    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 1.25, 3, nil)

    local function onInteract()
        world.removeObjectFromEnviroment(instance)
        text = ui.displayText(
            love.graphics.getWidth()/2 - love.graphics.getFont():getWidth("Picked up")/2,
            love.graphics.getHeight() - 100,
            "Picked up")

        player.addToInventory("screwdriver")
    end
    
    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, "Pickup Screwdriver", 15, 2, onInteract, true)
end

return Screwdriver