--// Bed
local utils = require("utils.utils")
local world = require("game.systems.world")
local worldspace = require("ui.worldspace")
local player = require("game.systems.player")
local ui = require("ui.ui")
local state = require("state.state")

local Bed = {}

local img_open = utils.setup_img("assets/sprites/enviroment/bed/bed_default.png")
local img_closed = utils.setup_img("assets/sprites/enviroment/Bed/bed_hiding.png") -- Fixed typo: was loading open.png twice

local sprites = {
    ["default"]   = world.createObject(img_open),
    ["hiding"] = world.createObject(img_closed)
}

local hidingMessage = "Press Q to exit hiding..."

function Bed.create(x, y, hasCollision)
    local isHidingInside = false

    local collisionBox = hasCollision and {
        x = 0, --// offset for colliding with edge
        y = 0, --// offset
        width = img_open:getWidth(),
        height = img_open:getHeight()
    } or nil

    local instance = world.insertObjectIntoEnviroment(sprites["default"], x, y, 1.75, 3, nil, collisionBox)

    local stored_x, stored_y
    local text

    local function onInteract()
        if isHidingInside then
            return
        end

        text = ui.displayText(
            love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(hidingMessage)/2,
            love.graphics.getHeight() - 100,
            hidingMessage)

        state.world["Lighting"].vignetteSize = state.world["Lighting"].hideVignetteSize

        player.setState("isHiding", true)

        print("hiding")
        isHidingInside = true 
        
        instance.obj = sprites["default"]
        state.player.currentHidingSpot = {
            exit = function ()
                state.world["Lighting"].vignetteSize = 1
                player.setState("isHiding", false)
                isHidingInside = false
                instance.obj = sprites["hiding"]
                text.remove()

                local centerX, centerY = utils.getObjectCenter(instance)
                worldspace.create_interact_worldspace_ui(centerX, centerY, "Hide", 35, 2, onInteract)
            end
        }

    end

    local centerX, centerY = utils.getObjectCenter(instance)
    worldspace.create_interact_worldspace_ui(centerX - 200, centerY - 50, "Hide", 35, 2, onInteract)
end

return Bed