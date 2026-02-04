local intruder = {}

local state = require("state.state")
local world = require("game.systems.world")
local fade = require("ui.fade")
local peachy = require("libraries.peachy")
local utils = require("utils.utils")
local worldui = require("ui.worldspace")
local player = require("game.systems.player")

local intruderState = nil
local sprite = nil
local scale = 0.65
local doorTimer = 0
local DOOR_WAIT_TIME = 2.5

local wonderTargetX = nil
local wonderTargetRoom = nil
local wonderWaitTimer = 0


local grabSpamMaxAmount = math.random(9,15)
local grabSpamAmount = 0
local grabSpamPrompt = nil
local stunningTimer = 0

local STATES = {
    ["FOLLOWING"] = "FOLLOWING",
    ["SEARCH"] = "SEARCH",
    ["WONDER"] = "WONDER"
}

local function setAnimation(name)
    if not intruderState then return end
    if intruderState.currentAnim ~= name then
        intruderState.currentAnim = name
        sprite:setTag(name)
        sprite:play()
    end
end

function intruder.init()
    intruderState = state.intruder
    intruderState.currentAnim = "Walk"
    intruderState.facingRight = false
    sprite = peachy.new("assets/sprites/intruder/intruder.json", utils.setup_img("assets/sprites/intruder/intruder.png"), "Walk")
    sprite:play()
end

function intruder.registerDoor(fromRoom, toRoom, doorX, spawnPos)
    local s = state.intruder
    if not s.roomGraph[fromRoom] then s.roomGraph[fromRoom] = {} end
    
    for _, conn in ipairs(s.roomGraph[fromRoom]) do
        if conn.target == toRoom and math.abs(conn.doorX - doorX) < 1 then return end
    end
    
    table.insert(s.roomGraph[fromRoom], {
        target = toRoom,
        doorX = doorX,
        spawnX = spawnPos.x,
        spawnY = spawnPos.y
    })
end

function intruder.findPathToRoom(fromRoom, toRoom)
    if fromRoom == toRoom then return nil end
    local s = state.intruder
    local visited = {}
    local queue = {{room = fromRoom, path = {}}}
    
    while #queue > 0 do
        local current = table.remove(queue, 1)
        
        if current.room == toRoom then 
            return current.path[1] 
        end
        
        if not visited[current.room] then
            visited[current.room] = true
            local connections = s.roomGraph[current.room]
            if connections then
                for _, conn in ipairs(connections) do
                    if not visited[conn.target] then
                        local newPath = {}
                        for _, p in ipairs(current.path) do
                            table.insert(newPath, p)
                        end
                        table.insert(newPath, conn)
                        table.insert(queue, {room = conn.target, path = newPath})
                    end
                end
            end
        end
    end
    return nil
end

function intruder.wonder(dt)
    if wonderWaitTimer > 0 then
        wonderWaitTimer = wonderWaitTimer - dt
        setAnimation("Idle")
        return
    end

    if wonderTargetRoom and intruderState.currentRoom ~= wonderTargetRoom then
        local nextDoor = intruder.findPathToRoom(intruderState.currentRoom, wonderTargetRoom)
        if nextDoor then
            intruder.moveTowardsDoor(dt, nextDoor)
        else
            wonderTargetRoom = nil
        end
        return
    end

    if wonderTargetX then
        local dx = intruderState.speed * dt
        if math.abs(wonderTargetX - intruderState.x) > 10 then
            intruderState.facingRight = wonderTargetX > intruderState.x
            local direction = intruderState.facingRight and 1 or -1
            local newX = intruderState.x + dx * direction
            setAnimation("Walk")
            if not world.checkCollision(newX, intruderState.y, intruderState.width, intruderState.height) then
                intruderState.x = newX
            else
                wonderTargetX = nil
                wonderWaitTimer = 18
            end
        else
            wonderTargetX = nil
            wonderWaitTimer = 18
        end
        return
    end

    if math.random() < 0.3 then
        local rooms = {}
        for room, _ in pairs(intruderState.roomGraph) do
            if room ~= intruderState.currentRoom then table.insert(rooms, room) end
        end
        if #rooms > 0 then
            wonderTargetRoom = rooms[math.random(#rooms)]
            wonderTargetX = math.random(200, 800)
        end
    else
        local maxX = intruderState.currentRoom == "hall" and 2800 or 1000
        wonderTargetX = math.random(100, maxX)
        wonderTargetRoom = nil
    end
end

function intruder.update(dt)
    intruderState = state.intruder
    if not intruderState.active then return end
    
    local playerRoom = state.world["CurrentLevel"]
    local myRoom = intruderState.currentRoom
    
    if sprite then sprite:update(dt) end
    
    local canSeePlayer = false
    local distToPlayer = math.huge
    
    if myRoom == playerRoom and not state.player.isHiding then
        local intruderCenterX = intruderState.x + intruderState.width / 2
        local intruderCenterY = intruderState.y + intruderState.height / 2
        local playerCenterX = state.player.x + state.player.width / 2
        local playerCenterY = state.player.y + state.player.height / 2
        
        local dx = playerCenterX - intruderCenterX
        local dy = playerCenterY - intruderCenterY
        distToPlayer = math.sqrt(dx * dx + dy * dy)
        
        local playerIsInFront = (intruderState.facingRight and dx > 0) or (not intruderState.facingRight and dx < 0)
        
        if playerIsInFront and distToPlayer < 800 then
            local steps = math.ceil(distToPlayer / 10)
            canSeePlayer = true
            
            for i = 1, steps do
                local t = i / steps
                local checkX = intruderCenterX + dx * t - intruderState.width / 2
                local checkY = intruderCenterY + dy * t - intruderState.height / 2
                
                if world.checkCollision(checkX, checkY, intruderState.width, intruderState.height) then
                    canSeePlayer = false
                    break
                end
            end
        end
    end
    
    if distToPlayer < 110 and stunningTimer <= 0 then
        intruder.grabPlayer()
    elseif grabSpamPrompt then
        worldui.remove_interact_worldspace_ui(grabSpamPrompt)
        grabSpamPrompt = nil
        state.player.isAbleToMove = true
    end
    
    if stunningTimer > 0 then
        stunningTimer = stunningTimer - dt
        setAnimation("Idle")
    end

    if grabSpamPrompt then
        grabSpamPrompt.x = state.player.px
        grabSpamPrompt.y = state.player.py
        setAnimation("Idle")
        return
    end

    if stunningTimer > 0 then return end
    
    local isChasing = intruderState.currentState == STATES["FOLLOWING"]
    
    if canSeePlayer or (isChasing and myRoom == playerRoom and not state.player.isHiding) then
        intruderState.currentState = STATES["FOLLOWING"]
        wonderTargetX, wonderTargetRoom, wonderWaitTimer = nil, nil, 0
        doorTimer = 0
        intruder.chasePlayer(dt)
    elseif myRoom ~= playerRoom and not state.player.isHiding then
        local nextDoor = intruder.findPathToRoom(myRoom, playerRoom)
        if nextDoor then
            intruderState.currentState = STATES["SEARCH"]
            wonderTargetX, wonderTargetRoom, wonderWaitTimer = nil, nil, 0
            intruder.moveTowardsDoor(dt, nextDoor)
        else
            intruderState.currentState = STATES["WONDER"]
            intruder.wonder(dt)
        end
    else
        intruderState.currentState = STATES["WONDER"]
        intruder.wonder(dt)
    end
end

function intruder.grabPlayer()
    state.player.isAbleToMove = false
    
    if not grabSpamPrompt then
        grabSpamPrompt = worldui.create_interact_worldspace_ui(
            state.player.px,
            state.player.py,
            state.translations[state.translations.currentLanguage]["PUSH_INTRUDER_HOLD_PROMPT"],
            150,
            0.025,
            function ()
                grabSpamPrompt = nil
                player.push()
                grabSpamAmount = grabSpamAmount + 1
                if grabSpamAmount >= grabSpamMaxAmount then
                    state.player.isAbleToMove = true
                    grabSpamAmount = 0
                    stunningTimer = 2.5
                end
            end,
            true
        )
    end
end

function intruder.chasePlayer(dt)
    local targetX = state.player.x
    local myX = intruderState.x
    local dx = intruderState.speed * dt
    
    if math.abs(targetX - myX) > 5 then
        intruderState.facingRight = targetX > myX
        local direction = intruderState.facingRight and 1 or -1
        local newX = myX + dx * direction
        setAnimation("Walk")
        if not world.checkCollision(newX, intruderState.y, intruderState.width, intruderState.height) then
            intruderState.x = newX
        end
    else
        setAnimation("Idle")
    end
end

function intruder.moveTowardsDoor(dt, doorInfo)
    local targetX = doorInfo.doorX
    local myX = intruderState.x
    local dx = intruderState.speed * dt
    
    if math.abs(targetX - myX) > 10 then
        intruderState.facingRight = targetX > myX
        local direction = intruderState.facingRight and 1 or -1
        local newX = myX + dx * direction
        setAnimation("Walk")
        if not world.checkCollision(newX, intruderState.y, intruderState.width, intruderState.height) then
            intruderState.x = newX
        end
    else
        setAnimation("Idle")
        doorTimer = doorTimer + dt
        if doorTimer >= DOOR_WAIT_TIME then
            intruder.transitionToRoom(doorInfo)
        end
    end
end

function intruder.transitionToRoom(doorInfo)
    intruderState.currentRoom = doorInfo.target
    intruderState.x = doorInfo.spawnX
    intruderState.y = doorInfo.spawnY
    doorTimer = 0
end

function intruder.draw()
    intruderState = state.intruder
    if not intruderState.active or intruderState.currentRoom ~= state.world["CurrentLevel"] or not sprite then return end
    
    local sx = intruderState.facingRight and scale or -scale
    local w, h = sprite:getWidth(), sprite:getHeight()
    sprite:draw(intruderState.x + intruderState.width / 2, intruderState.y + intruderState.height / 2, 0, sx, scale, w / 2, h / 2)
end

function intruder.setPosition(x, y)
    state.intruder.x, state.intruder.y = x, y
end

function intruder.setRoom(roomName)
    state.intruder.currentRoom = roomName
end

return intruder
