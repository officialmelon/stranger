local gameplay = {}

--// Modules
local modules = {
    ["state"] = require("state.state"),
    ["ui"] = require("ui.ui"),
    ["mic"] = require("game.systems.mic"),
    ["camera"] = require("game.systems.camera"),
    ["player"] = require("game.systems.player"),
    ["world"] = require("game.systems.world"),
    ["effects"] = require("game.systems.effects")
}

--// Stuff

function gameplay.init()
    modules["mic"].init()
end

function gameplay.loadLevel(levelName) --// Level handler
    assert(levelName)

    local loaded_level = require("game.levels." .. levelName)
    modules["state"].world["CurrentLevel"] = loaded_level

    loaded_level.load()
end

function gameplay.draw()
    modules["camera"].apply()
    modules["world"].draw()
    modules["player"].draw()
    modules["camera"].pop()
    modules["effects"].draw()
    modules["ui"].draw()
end

function gameplay.update(dt)
    modules["camera"].update(dt)
    modules["player"].update(dt)
    modules["world"].update(dt)
    modules["ui"].update(dt)
end

return gameplay