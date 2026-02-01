local player = {}

--// Modules
local state = require("state.state")
local peachy = require("libraries.peachy")
local utils = require("utils.utils")

--// Sprite

local Sprites = {
    ["Player"] = peachy.new("assets/sprites/player/walking.json", utils.setup_img("assets/sprites/player/walking.png"), "Walk")
}

local Binds = {
    ["Right"] = "d",
    ["Left"] = "a",

    ["exitHiding"] = "q"
}

--// Controllers
function player.goTo(x, y)
    state.player.x = x
    state.player.y = y
end

function player.setState(flag, flagState)
    state.player[flag] = flagState
end

--// Handlers
function player.draw()
    if state.player.isHiding then return end

    local s = state.player.scale or 1
    local sx = state.player.facingRight and s or -s
    local ox = Sprites["Player"]:getWidth() / 2
    local oy = 0
    Sprites["Player"]:draw(state.player.x + ox, state.player.y + oy, 0, sx, s, ox, oy)
end



function player.update(dt)
    if state.player.isHiding then
        if love.keyboard.isDown(Binds["exitHiding"]) then
            if state.player.currentHidingSpot then
                state.player.currentHidingSpot.exit()
            end
        end
        return
    end

    Sprites["Player"]:update(dt)
    state.player.width = Sprites["Player"]:getWidth() * state.player.scale
    state.player.height = Sprites["Player"]:getHeight() * state.player.scale
    
    local dx = state.player.speed * dt
    local world = require("game.systems.world")

    if love.keyboard.isDown(Binds["Right"]) then
        state.player.facingRight = true
        Sprites["Player"]:play()
        
        local newX = state.player.x + dx
        if not world.checkCollision(newX, state.player.y, state.player.width, state.player.height) then
            state.player.x = newX
        end

    elseif love.keyboard.isDown(Binds["Left"]) then
        state.player.facingRight = false
        Sprites["Player"]:play()
        
        local newX = state.player.x - dx
        if not world.checkCollision(newX, state.player.y, state.player.width, state.player.height) then
            state.player.x = newX
        end

    else
        Sprites["Player"]:stop()
    end
end

return player