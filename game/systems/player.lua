local player = {}

--// Modules
local state = require("state.state")
local peachy = require("libraries.peachy")
local utils = require("utils.utils")
local camera = require("game.systems.camera")
local sounds = require("game.systems.sound")

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

local footstepTimer = 0
local footstepInterval = 0.4

--// Controllers
function player.goTo(x, y)
    state.player.x = x
    state.player.y = y
end

function player.setState(flag, flagState)
    state.player[flag] = flagState
end

function player.getCameraTarget()
    return {
        x = state.player.x + state.player.width / 2,
        y = state.player.y + state.player.height / 2 + state.world.Camera.y_offset
    }
end

function player.setAnimation(name)
    if currentSprite ~= name then
        Sprites[currentSprite]:stop()
        currentSprite = name
        Sprites[name]:play()
    end
end

function player.addToInventory(itemName)
    if #state.player.inventory >= state.player.maxSlots then return end
    sounds.play("item_pickup")
    table.insert(state.player.inventory, {
        name = itemName,
        sprite = utils.setup_img("assets/sprites/items/" .. itemName .. "/" .. itemName .. ".png")
    })
end

function player.equipItem(slot)
    if not state.player.inventory[slot] then 
    state.player.equippedItem = nil
    return 
    end
    state.player.equippedItem = state.player.inventory[slot]
end

--// Handlers
function player.draw()
    if state.player.isHiding then return end

    local s = state.player.scale or 1
    local sx = state.player.facingRight and s or -s

    local hitW, hitH = state.player.width, state.player.height
    local sprite = Sprites[currentSprite]
    local spriteW, spriteH = sprite:getWidth(), sprite:getHeight()

    local drawX = state.player.x + hitW / 2
    local drawY = state.player.y + hitH / 2

    sprite:draw(
        drawX,
        drawY,
        0,
        sx,
        s,
        spriteW / 2,
        spriteH / 2
    )

    local equippedItem = state.player.equippedItem
    if equippedItem then
        local img = equippedItem.sprite
        local iw, ih = img:getWidth(), img:getHeight()

        local itemScale = s
        
        local itemDrawY = drawY - (spriteH / 4)
        
        love.graphics.draw(
            img,
            drawX,
            itemDrawY,
            0,
            -sx * itemScale,
            itemScale,
            iw / 2,
            ih / 2
        )
    end
end

function player.keypressed(key)
    local slot = tonumber(key)
    if slot and slot >= 1 and slot <= 5 then
        player.equipItem(slot)
    end
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
        footstepTimer = footstepTimer + dt
        local interval = sprinting and footstepInterval * 0.6 or footstepInterval
        if footstepTimer >= interval then
            local footstep = math.random(1, 2)
            local pitch = 0.8 + math.random() * 0.4
            sounds.play("footstep_" .. footstep, 0.3, pitch, false)
            footstepTimer = 0
        end
    else
        player.setAnimation("Idle")
        footstepTimer = 0
    end
    
    state.player.px = state.player.x + 300 / 2
    state.player.py = state.player.y + state.player.height / 2

    Sprites[currentSprite]:update(dt * (sprinting and state.player.sprintAnimationMultiplier or 1))
end

return player