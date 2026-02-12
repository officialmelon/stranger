local intruder = {}

local state    = require("state.state")
local world    = require("game.systems.world")
local fade     = require("ui.fade")
local peachy   = require("libraries.peachy")
local utils    = require("utils.utils")
local worldui  = require("ui.worldspace")
local player   = require("game.systems.player")
local mic      = require("game.systems.mic")
local camera   = require("game.systems.camera")

local intruderState    = nil
local sprite           = nil
local scale            = 0.65
local doorTimer        = 0
local DOOR_WAIT_TIME   = 2.0
local grabSpamMaxAmount = 14
local grabSpamAmount   = 0
local grabSpamPrompt   = nil
local grabTimer        = 0
local GRAB_TIMEOUT     = 3.0
local stunningTimer    = 0
local lastKnownX       = nil
local lastKnownRoom    = nil
local searchTimer      = 0
local patrolTimer      = 0
local hearingRadius    = 500
local visionDistance   = 800

local STATES = {
    IDLE            = "IDLE",
    PATROL          = "PATROL",
    CHASE           = "CHASE",
    INVESTIGATE     = "INVESTIGATE",
    SEARCH_ROOM     = "SEARCH_ROOM",
    DISTRACTED      = "DISTRACTED",
    SCRIPTED_CHASE  = "SCRIPTED_CHASE"
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

    if state.story.isPhase(1) then
        intruderState.active = false
        intruderState.currentState = STATES.IDLE
    else
        intruderState.active = true
        intruderState.currentState = STATES.PATROL
    end

    sprite = peachy.new("assets/sprites/intruder/intruder.json", utils.setup_img("assets/sprites/intruder/intruder.png"), "Walk")
    sprite:play()
end

function intruder.registerDoor(fromRoom, toRoom, doorX, spawnPos)
    local s = state.intruder

    if not s.roomGraph[fromRoom] then 
        s.roomGraph[fromRoom] = {} 
    end

    for _, conn in ipairs(s.roomGraph[fromRoom]) do
        if conn.target == toRoom and math.abs(conn.doorX - doorX) < 1 then 
            return 
        end
    end

    table.insert(s.roomGraph[fromRoom], {
        target = toRoom,
        doorX  = doorX,
        spawnX = spawnPos.x,
        spawnY = spawnPos.y
    })
end

function intruder.findPathToRoom(fromRoom, toRoom)
    if fromRoom == toRoom then return nil end

    local s = state.intruder
    local visited = {}
    local queue   = {{room = fromRoom, path = {}}}

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

function intruder.canSeePlayer()
    local pRoom = state.world["CurrentLevel"]
    local iRoom = intruderState.currentRoom

    if iRoom ~= pRoom or state.player.isHiding then 
        return false, math.huge 
    end

    local ix, iy = intruderState.x + intruderState.width / 2, intruderState.y + intruderState.height / 2
    local px, py = state.player.x + state.player.width / 2, state.player.y + state.player.height / 2
    local dx, dy = px - ix, py - iy
    local dist   = math.sqrt(dx*dx + dy*dy)

    if dist > visionDistance then 
        return false, dist 
    end

    local facing = intruderState.facingRight and 1 or -1

    if (dx * facing) < -100 then 
        return false, dist 
    end

    local steps = math.ceil(dist / 15)

    for i = 1, steps do
        local t = i / steps
        if world.checkCollision(ix + dx * t - 5, iy + dy * t - 5, 10, 10) then 
            return false, dist 
        end
    end

    return true, dist
end

function intruder.checkHearing()
    local pRoom = state.world["CurrentLevel"]

    if intruderState.currentRoom ~= pRoom then 
        return false 
    end

    local micVol  = mic and mic.getMicVolume() or 0
    local moveVol = (state.player.isMoving and not state.player.isCrouching) and 0.4 or 0

    if state.player.isRunning then 
        moveVol = 1.0 
    end

    local noise = (micVol * 15) + moveVol

    if noise < 0.2 then 
        return false 
    end

    local dist = math.huge

    if state.player.x then 
        dist = math.abs(state.player.x - intruderState.x) 
    end

    if dist < (hearingRadius * noise) then 
        return true, state.player.x 
    end

    return false
end

function intruder.startScriptedChase(room, x, y)
    intruderState.active = true
    intruderState.currentRoom = room
    intruderState.x = x
    intruderState.y = y
    intruderState.currentState = STATES.SCRIPTED_CHASE
    state.story.flags.intruderSpawned = true
    state.story.setStep("intruder_chase")
    state.world.Camera.shake.intensity = 3
    state.world.Camera.shake.duration = 0.6
end

function intruder.alertToRoom(room, x)
    if not intruderState or not intruderState.active then return end
    intruderState.currentState = STATES.CHASE
    lastKnownX = x
    lastKnownRoom = room
end

function intruder.deactivate()
    if not intruderState then return end
    intruderState.active = false
    intruderState.currentState = STATES.IDLE
end

function intruder.activate()
    if not intruderState then return end
    intruderState.active = true
    intruderState.currentState = STATES.PATROL
end

function intruder.update(dt)
    if not intruderState then return end

    if state.story.isPhase(1) and state.story.flags.coffeeFound and not state.story.flags.intruderSpawned then
        local pRoom = state.world["CurrentLevel"]
        intruder.startScriptedChase(pRoom, state.player.x + 600, intruderState.y)
    end

    if not intruderState.active then return end

    if sprite and stunningTimer <= 0 then 
        sprite:update(dt) 
    end

    if stunningTimer > 0 then
        if grabSpamPrompt then
            worldui.remove_interact_worldspace_ui(grabSpamPrompt)
            grabSpamPrompt = nil
            state.player.isAbleToMove = true
        end

        stunningTimer = stunningTimer - dt
        setAnimation("Idle")
        return
    end

    if grabSpamPrompt then
        grabSpamPrompt.x, grabSpamPrompt.y = state.player.px, state.player.py
        setAnimation("Idle")

        grabTimer = grabTimer - dt
        if grabTimer <= 0 then
            worldui.remove_interact_worldspace_ui(grabSpamPrompt)
            grabSpamPrompt = nil
            intruder.onGrabFail()
        end

        return
    end

    if intruderState.currentState == STATES.SCRIPTED_CHASE then
        state.player.facingRight = intruderState.x > state.player.x
        intruder.moveTowards(dt, state.player.x, 1.6)
        local dx = state.player.x - intruderState.x
        local dist = math.abs(dx)
        if dist < 110 then
            intruder.grabPlayer()
        end
        return
    end

    local canSee, dist = intruder.canSeePlayer()
    local heard, hX   = intruder.checkHearing()

    if canSee then
        intruderState.currentState = STATES.CHASE
        lastKnownX, lastKnownRoom = state.player.x, state.world["CurrentLevel"]
        intruderState.knowsHidingSpot = false
    elseif heard and intruderState.currentState ~= STATES.CHASE then
        intruderState.currentState = STATES.INVESTIGATE
        lastKnownX, lastKnownRoom = hX, state.world["CurrentLevel"]
    end

    if intruderState.currentState == STATES.CHASE then
        if canSee then
            intruder.moveTowards(dt, state.player.x, 1.4)

            if dist < 110 then 
                intruder.grabPlayer() 
            end
        else
            searchTimer = 2
            intruderState.currentState = STATES.SEARCH_ROOM
        end

    elseif intruderState.currentState == STATES.INVESTIGATE or intruderState.currentState == STATES.DISTRACTED then
        if lastKnownRoom and intruderState.currentRoom ~= lastKnownRoom then
            local door = intruder.findPathToRoom(intruderState.currentRoom, lastKnownRoom)

            if door then 
                intruder.moveTowardsDoor(dt, door) 
            else 
                intruderState.currentState = STATES.PATROL 
            end

        elseif lastKnownX then
            if math.abs(intruderState.x - lastKnownX) > 20 then
                intruder.moveTowards(dt, lastKnownX, 1.1)
            else
                searchTimer = 4
                intruderState.currentState = STATES.SEARCH_ROOM
            end
        else
            intruderState.currentState = STATES.PATROL
        end

    elseif intruderState.currentState == STATES.SEARCH_ROOM then
        searchTimer = searchTimer - dt

        if searchTimer <= 0 then
            intruderState.currentState = STATES.PATROL
        else
            setAnimation("Idle")
            if math.random() < 0.02 then 
                intruderState.facingRight = not intruderState.facingRight 
            end
        end

    elseif intruderState.currentState == STATES.PATROL then
        patrolTimer = patrolTimer - dt

        if patrolTimer <= 0 then
            local rooms = {}

            for r, _ in pairs(intruderState.roomGraph) do 
                table.insert(rooms, r) 
            end

            if #rooms > 0 then
                lastKnownRoom = rooms[math.random(#rooms)]
                lastKnownX    = math.random(200, 800)
                patrolTimer   = math.random(5, 15)
                intruderState.currentState = STATES.INVESTIGATE
            end
        end

        setAnimation("Idle")
    end
end

function intruder.moveTowards(dt, tx, sm)
    local s    = intruderState.speed * (sm or 1)
    local step = s * dt

    if math.abs(tx - intruderState.x) > 5 then
        intruderState.facingRight = tx > intruderState.x
        local nx = intruderState.x + (intruderState.facingRight and step or -step)
        setAnimation("Walk")

        if not world.checkCollision(nx, intruderState.y, intruderState.width, intruderState.height) then
            intruderState.x = nx
        else
            searchTimer = 1.5
            intruderState.currentState = STATES.SEARCH_ROOM
        end
    else
        setAnimation("Idle")
    end
end

function intruder.moveTowardsDoor(dt, door)
    if math.abs(door.doorX - intruderState.x) > 20 then
        intruder.moveTowards(dt, door.doorX, 1.0)
    else
        setAnimation("Idle")
        doorTimer = doorTimer + dt

        if doorTimer >= DOOR_WAIT_TIME then
            intruderState.currentRoom = door.target
            intruderState.x, intruderState.y = door.spawnX, door.spawnY
            doorTimer = 0
        end
    end
end

function intruder.grabPlayer()
    if stunningTimer > 0 or grabSpamPrompt then return end

    if state.story.isPhase(1) then
        state.player.isAbleToMove = false
        intruderState.active = false
        state.story.setStep("caught")
        state.world.Camera.shake.intensity = 5
        state.world.Camera.shake.duration = 1.5
        fade.Out(function()
            state.story.advancePhase()
            state.story.flags.intruderSpawned = false
            state.story.flags.coffeeFound = false
            intruderState.active = true
            intruderState.currentState = STATES.PATROL
            intruderState.currentRoom = "living_room"
            intruderState.x, intruderState.y = 100, 475
            state.player.isAbleToMove = true
            state.world.isStartOfGame = true
            local gameplay = require("game.scenes.gameplay")
            gameplay.loadLevel("bedroom")
            player.goTo(15, 475)
            fade.In(2.5)
        end, 2.0)
        return
    end

    if intruderState.knowsHidingSpot and state.player.isHiding and state.player.currentHidingSpot then
        intruderState.knowsHidingSpot = false
        state.player.currentHidingSpot.exit()
    end

    state.player.isAbleToMove = false
    intruderState.facingRight = state.player.x > intruderState.x
    state.player.facingRight  = not intruderState.facingRight
    grabSpamAmount = 0
    grabTimer = GRAB_TIMEOUT

    grabSpamPrompt = worldui.create_interact_worldspace_ui(
        state.player.px, 
        state.player.py, 
        state.translations[state.translations.currentLanguage]["PUSH_INTRUDER_HOLD_PROMPT"], 
        150, 
        0.025, 
        function()
            player.push()
            grabSpamAmount = grabSpamAmount + 1

            if grabSpamAmount >= grabSpamMaxAmount then
                worldui.remove_interact_worldspace_ui(grabSpamPrompt)
                grabSpamPrompt = nil
                grabTimer = 0
                state.player.isAbleToMove = true
                stunningTimer = 4.0
            end
        end, 
        false
    )
end

function intruder.onGrabFail()
    state.player.isAbleToMove = false
    intruderState.active = false
    state.world.Camera.shake.intensity = 5
    state.world.Camera.shake.duration = 1.5
    fade.Out(function()
        if state.story.isPhase(2) and state.story.isAtLeastStep("going_upstairs") then
            state.story.step = "found_smartphone"
        elseif state.story.isPhase(3) then
            state.story.step = "vent_banging"
        end

        if state.story.isPhase(3) then
            intruderState.active = false
            intruderState.currentState = STATES.IDLE
        else
            intruderState.active = true
            intruderState.currentState = STATES.PATROL
        end

        intruderState.currentRoom = "living_room"
        intruderState.x, intruderState.y = 100, 475
        state.player.isAbleToMove = true
        local gameplay = require("game.scenes.gameplay")
        gameplay.loadLevel("bedroom")
        player.goTo(15, 475)
        fade.In(2.5)
    end, 2.0)
end

function intruder.draw()
    if not intruderState or not intruderState.active or intruderState.currentRoom ~= state.world["CurrentLevel"] or not sprite then return end

    local sx   = intruderState.facingRight and scale or -scale
    local w, h = sprite:getWidth(), sprite:getHeight()

    sprite:draw(
        intruderState.x + intruderState.width/2, 
        intruderState.y + intruderState.height/2, 
        0, 
        sx, 
        scale, 
        w/2, 
        h/2
    )
end

function intruder.stun(d) stunningTimer = d end

function intruder.setPosition(x, y) 
    intruderState.x, intruderState.y = x, y 
end

function intruder.setRoom(r) 
    intruderState.currentRoom = r 
end

function intruder.gotoPoint(r, x) 
    lastKnownRoom, lastKnownX, intruderState.currentState = r, x, STATES.DISTRACTED 
end

function intruder.onPlayerHide()
    local see, _ = intruder.canSeePlayer()
    if see then 
        intruderState.knowsHidingSpot = true
        intruder.gotoPoint(state.world.CurrentLevel, state.player.x) 
    end
end

return intruder
