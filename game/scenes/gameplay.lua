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
    ["fade"] = require("ui.fade")
}

--// Stuff

function gameplay.init()
    modules["mic"].init()
end

function gameplay.loadLevel(levelName) --// Level handler
    assert(levelName)

    modules["state"].world["Enviroment"]["Objects"] = {}
    modules["worldspace"].clear_worldspace_ui()

    local loaded_level = require("game.levels." .. levelName)
    modules["state"].world["CurrentLevel"] = levelName

    loaded_level.load()
end

function gameplay.draw()
    modules["camera"].apply()
    modules["world"].draw()
    modules["player"].draw()
    modules["worldspace"].draw()
    modules["camera"].pop()
    modules["effects"].draw()
    modules["ui"].draw()
    modules["fade"].draw()

    --// debug
    love.graphics.print(modules["state"].world["CurrentLevel"],0,0)
end

function gameplay.update(dt)
    modules["camera"].setTarget(modules["player"].getCameraTarget())
    modules["fade"].update(dt)
    modules["player"].update(dt)
    modules["camera"].update(dt)
    modules["world"].update(dt)
    modules["ui"].update(dt)
    modules["worldspace"].update(dt)
end

return gameplay