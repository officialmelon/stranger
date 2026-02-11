return {
    ["Enviroment"] = {
        ["Objects"] = {

        }
    },

    ["Lighting"] = {
        vignetteSize = 1,
        hideVignetteSize = 1.5,
        defaultVignetteSize = 1
    },
    ["WorldObj"] = love.physics.newWorld(),
    ["Camera"] = {
        x=0,
        y=0,
        target = {
            x=0,
            y=0
        },
        smooth = 6,
        scale = 1.5,

        y_offset = 0,

        shake = {
            intensity = 0,
            duration = 0,
            time = 0
        }
    },
    windows = {},

    ["CurrentLevel"] = nil,

    isEditMode = false,
    isStartOfGame = true,

    ["PersistentState"] = {}
}