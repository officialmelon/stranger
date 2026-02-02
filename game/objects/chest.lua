--// Chest
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")

local Chest = {}

local img_open = utils.setup_img("assets/sprites/enviroment/chest/chest_open.png")
local img_closed = utils.setup_img("assets/sprites/enviroment/chest/chest_closed.png")

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

        text = ui.displayText(
            1280/2 - love.graphics.getFont():getWidth(hidingMessage)/2,
            720 - 100,
            hidingMessage)

        state.world["Lighting"].vignetteSize = state.world["Lighting"].hideVignetteSize

        player.setState("isHiding", true)

        print("hiding")
        isHidingInside = true 
        
        instance.obj = sprites["open"]
        state.player.currentHidingSpot = {
            exit = function ()
                state.world["Lighting"].vignetteSize = 1
                player.setState("isHiding", false)
                isHidingInside = false
                instance.obj = sprites["closed"]
                text.remove()

                local centerX, centerY = utils.getObjectCenter(instance)
                worldspace.create_interact_worldspace_ui(centerX, centerY, "Hide", 25, 2, onInteract, false)
                end
        }
    end

    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX, centerY, "Hide", 25, 2, onInteract, false)
end

return Chest