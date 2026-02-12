local Story = {}

Story.currentPhase = 1
Story.step = "wake_up"

Story.phaseSteps = {
    [1] = { "wake_up", "heard_noise", "investigating", "found_coffee", "intruder_chase", "caught" },
    [2] = { "wake_up", "found_screwdriver", "open_vent", "in_hall", "found_phone", "found_key", "opened_safe", "found_smartphone", "going_upstairs", "locked_in_room" },
    [3] = { "wake_up", "call_police", "phone_dead", "banging_stops", "vent_banging", "escape_bathroom", "find_hiding_spot", "ending" }
}

Story.objectives = {
    [1] = "NOISE_INVESTIGATE",
    [2] = "UNLOCK_VENT_INVESTIGATE",
    [3] = "DIAL_911_SMARTPHONE_PROMPT"
}

Story.flags = {
    hasScrewdriver = false,
    hasSmartphone = false,
    hasHandgun = false,
    hasKey = false,
    coffeeFound = false,
    ventOpened = false,
    phoneDead = false,
    signalReached = false,
    intruderSpawned = false,
    landlineUsed = false,
    safeOpened = false
}

function Story.getStepIndex(phase, step)
    local steps = Story.phaseSteps[phase]
    if not steps then return 0 end
    for i, s in ipairs(steps) do
        if s == step then return i end
    end
    return 0
end

function Story.setStep(newStep)
    Story.step = newStep
    Story.refreshTask()
end

function Story.advancePhase()
    Story.currentPhase = Story.currentPhase + 1
    Story.step = "wake_up"
end

function Story.isPhase(p)
    return Story.currentPhase == p
end

function Story.isStep(step)
    return Story.step == step
end

function Story.isAtLeastStep(step)
    local current = Story.getStepIndex(Story.currentPhase, Story.step)
    local target = Story.getStepIndex(Story.currentPhase, step)
    return current >= target
end

function Story.isPast(phase)
    return Story.currentPhase > phase
end

function Story.refreshTask()
    local ui = require("ui.ui")
    ui.clearTasks()
    ui.addTask(Story.getObjectiveText())
end

function Story.getObjectiveText()
    local state = require("state.state")
    local lang = state.translations.currentLanguage
    
    local key = Story.objectives[Story.currentPhase]
    
    if Story.currentPhase == 2 then
        if not Story.flags.hasScrewdriver then
            key = "BEDROOM_INVESTIGATE"
        elseif not Story.flags.ventOpened then
            key = "UNLOCK_VENT_INVESTIGATE"
        elseif not Story.flags.landlineUsed then
            key = "INVESTIGATE_LANDLINE"
        elseif not Story.flags.hasKey then
            key = "INVESTIGATE_FOR_ITEMS"
        elseif not Story.flags.safeOpened then
            key = "SEARCH_FOR_SAFE"
        elseif not Story.flags.hasSmartphone then
            key = "INVESTIGATE_FOR_ITEMS"
        elseif Story.isAtLeastStep("going_upstairs") then
            key = "FIND_ROOM"
        else
            key = "GET_SOMEWHERE_SAFE"
        end
    elseif Story.currentPhase == 3 then
        if not Story.flags.phoneDead then
            key = "CALL_911"
        elseif Story.isAtLeastStep("vent_banging") then
            key = "FIND_HIDING_SPOT"
        else
            key = "DOOR_LOCKED_SAFE"
        end
    end
    
    return state.translations[lang][key] or "..."
end

return Story