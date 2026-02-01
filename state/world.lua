return {
    ["Enviroment"] = {
        ["Objects"] = {

        }
    },

    ["Lighting"] = {
        vignetteSize = 1,
        hideVignetteSize = 1.5
    },
    ["WorldObj"] = love.physics.newWorld(),
    ["Camera"] = {
        x = 0,
        y = 250,
        smooth = 6,
        scale = 1.5,

        y_offset = 100,

        shake = {
            intensity = 0,
            duration = 0,
            time = 0
        }
    },
    ["CurrentLevel"] = nil
}