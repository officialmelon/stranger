local player = {}

--// Modules
local state = require("state.state")
local peachy = require("libraries.peachy")
local utils = require("utils.utils")

--// Sprite

local currentSprite = "Idle"
local moving = false

local Sprites = {
    ["Player"] = peachy.new("assets/sprites/player/walking.json", utils.setup_img("assets/sprites/player/walking.png"), "Walk"),
    ["Idle"] = peachy.new("assets/sprites/player/walking.json", utils.setup_img("assets/sprites/player/walking.png"), "Idle")
}

Sprites[currentSprite]:play()

local Binds = {
    ["Right"] = "d",
    ["Left"] = "a",
    ["Sprint"] = "lshift",

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

function player.setAnimation(name)
    if currentSprite ~= name then
        Sprites[currentSprite]:stop()
        currentSprite = name
        Sprites[name]:play()
    end
end

--// Handlers
function player.draw()
    if state.player.isHiding then return end

    local s = state.player.scale or 1
    local sx = state.player.facingRight and s or -s
    local ox = Sprites["Player"]:getWidth() / 2
    local oy = 0
    Sprites[currentSprite]:draw(state.player.x + ox, state.player.y + oy, 0, sx, s, ox, oy)
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
    moving = false

    state.player.width = Sprites["Player"]:getWidth() * state.player.scale
    state.player.height = Sprites["Player"]:getHeight() * state.player.scale
    
    local dx = state.player.speed * dt
    local world = require("game.systems.world")

    moving = love.keyboard.isDown(Binds["Right"]) or love.keyboard.isDown(Binds["Left"]) or false

    local sprinting = love.keyboard.isDown(Binds["Sprint"]) and state.player.stamina > 0 and moving
    if sprinting then
        dx = dx * state.player.sprintMultiplier
        state.player.stamina = math.max(0, state.player.stamina - state.player.staminaDrainRate * dt)
    else
        state.player.stamina = math.min(state.player.maxStamina, state.player.stamina + state.player.staminaRegenRate * dt)
    end

    if love.keyboard.isDown(Binds["Right"]) then
        state.player.facingRight = true
        
        local newX = state.player.x + dx
        if not world.checkCollision(newX, state.player.y, state.player.width, state.player.height) then
            state.player.x = newX
        end
    elseif love.keyboard.isDown(Binds["Left"]) then
        state.player.facingRight = false
        
        local newX = state.player.x - dx
        if not world.checkCollision(newX, state.player.y, state.player.width, state.player.height) then
            state.player.x = newX
        end
    end
    if moving then
        player.setAnimation("Player")
    else
        player.setAnimation("Idle")
    end
    
    state.player.px = state.player.x + 300 / 2
    state.player.py = state.player.y + state.player.height / 2

    Sprites[currentSprite]:update(dt * (sprinting and state.player.sprintAnimationMultiplier or 1))
end

return player