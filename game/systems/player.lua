local player = {}

--// Modules
local state = require("state.state")
local peachy = require("libraries.peachy")
local utils = require("utils.utils")

--// Sprite

local Sprites = {
    ["Player"] = peachy.new("assets/sprites/player/crawl.json", love.graphics.newImage("assets/sprites/player/crawl.png"), "Crawl")
}

local Binds = {
    ["Right"] = "d",
    ["Left"] = "a"
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
    local s = state.player.scale or 1
    Sprites["Player"]:draw(state.player.x, state.player.y, 0, s, s)
end


function player.update(dt)
    Sprites["Player"]:update(dt)
    if love.keyboard.isDown(Binds["Right"]) then
        Sprites["Player"]:play()
        state.player.x = utils.clamp(0, state.player.x + state.player.speed, love.graphics.getWidth()) 
    elseif love.keyboard.isDown(Binds["Left"]) then
        Sprites["Player"]:play()
        state.player.x = utils.clamp(0, state.player.x - state.player.speed, love.graphics.getWidth()) 
    else
        --// no movement
        Sprites["Player"]:stop()
    end
end

return player