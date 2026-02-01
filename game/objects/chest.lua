--// Chest
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")

local Chest = {}

local img_open = utils.setup_img("assets/sprites/enviroment/chest/chest_open.png")
local img_closed = utils.setup_img("assets/sprites/enviroment/chest/chest_closed.png") -- Fixed typo: was loading open.png twice

local sprites = {
    ["open"]   = world.createObject(img_open),
    ["closed"] = world.createObject(img_closed)
}

local hidingMessage = "Press Q to exit hiding..."

function Chest.create(x, y)
    local isHidingInside = false

    local instance = world.insertObjectIntoEnviroment(sprites["closed"], x, y, 1.25, 3)

    local stored_x, stored_y
    local text

    local function onInteract()
        if isHidingInside then
            return
        end

        stored_x, stored_y = x, y
        text = ui.displayText(
            love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(hidingMessage)/2,
            love.graphics.getHeight() - 100,
            hidingMessage)

        player.goTo(x,y)
        player.setState("isHiding", true)

        print("hiding")
        isHidingInside = true 
        
        instance.obj = sprites["open"]
    end

    worldspace.create_interact_worldspace_ui(x, y, "Hide", 15, 2, onInteract)

    local returnTable =  {
        exit = function ()
            player.setState("isHiding", false)
            player.goTo(stored_x, stored_y)
            isHidingInside = false
            instance.obj = sprites["closed"]
            text.remove()

            worldspace.create_interact_worldspace_ui(x, y, "Hide", 15, 2, onInteract)
        end
    }

    state.player.currentHidingSpot = returnTable
end

return Chest