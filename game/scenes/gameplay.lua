local gameplay = {}

--// Modules
local modules = {
    ["state"] = require("state.state"),
    ["ui"] = require("ui.ui"),
    ["mic"] = require("game.systems.mic"),
    ["camera"] = require("game.systems.camera"),
    ["player"] = require("game.systems.player"),
    ["world"] = require("game.systems.world"),
    ["effects"] = require("game.systems.effects"),
    ["worldspace"] = require("ui.worldspace"),
    ["fade"] = require("ui.fade"),
    ["sounds"] = require("game.systems.sound"),
    ["intruder"] = require("game.systems.intruder")
}

--// Stuff

local currentLevel = nil

function gameplay.init()
    modules["mic"].init()
    modules["player"].initRain()
    modules["intruder"].init()
end

function gameplay.loadLevel(levelName, diffFolder)
    assert(levelName)

    if currentLevel and currentLevel.kill then
        currentLevel.kill()
    end

    modules["world"].clear()
    modules["worldspace"].clear_worldspace_ui()
    modules["ui"].clearTasks()
    
    local modulePath
    if diffFolder and #diffFolder >= 1 then
        modulePath = diffFolder .. levelName
    else
        modulePath = "game.levels." .. levelName
    end
    package.loaded[modulePath] = nil
    local loaded_level = require(modulePath)
    
    modules["state"].world["CurrentLevel"] = levelName
    print(levelName)
    loaded_level.load()

    currentLevel = loaded_level

    local storyTask = modules["state"].story.getObjectiveText()
    if storyTask then
        modules["ui"].addTask(storyTask)
    end
end

function gameplay.draw()
    modules["camera"].apply()
    modules["world"].draw()
    modules["intruder"].draw()
    modules["player"].draw()
    modules["worldspace"].draw()
    modules["camera"].pop()
    modules["effects"].draw()
    modules["ui"].draw()
    modules["fade"].draw()
end

function gameplay.keypressed(key)
    modules["player"].keypressed(key)
end

function gameplay.mousepressed(x, y, button)
    modules["player"].mousepressed(x, y, button)
end

function gameplay.update(dt)
    modules["camera"].setTarget(modules["player"].getCameraTarget())
    modules["fade"].update(dt)
    modules["player"].update(dt)
    modules["camera"].update(dt)
    modules["world"].update(dt)
    modules["ui"].update(dt)
    modules["worldspace"].update(dt)
    modules["sounds"].update(dt)
    modules["intruder"].update(dt)

    if currentLevel and currentLevel.update then
        currentLevel.update(dt)
    end
end

return gameplay