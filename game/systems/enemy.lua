local Pathfinding = require("game.systems.pathfinding")

local AI = {}

local currentPath = nil
local PATH_SPEED = 120

function AI.startMoveTo(entityState, targetX, targetY)
    currentPath = Pathfinding.findPath(
        { x = entityState.x, y = entityState.y },
        { x = targetX, y = targetY }
    )
end

function AI.update(dt, entityState)
    if not currentPath or #currentPath == 0 then return end

    local target = currentPath[1]
    local dx = target.x - entityState.x
    local dy = target.y - entityState.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < 4 then
        table.remove(currentPath, 1)
    else
        entityState.x = entityState.x + (dx / dist) * PATH_SPEED * dt
        entityState.y = entityState.y + (dy / dist) * PATH_SPEED * dt
    end
end

function AI.draw(entityState)

    Pathfinding.debugDrawGrid()

    if currentPath and #currentPath > 1 then
        love.graphics.setColor(0, 0.6, 1, 0.9)
        love.graphics.setLineWidth(2)
        local points = {}
        table.insert(points, entityState.x)
        table.insert(points, entityState.y)
        for _, wp in ipairs(currentPath) do
            table.insert(points, wp.x)
            table.insert(points, wp.y)
        end
        love.graphics.line(table.unpack(points))
        love.graphics.setLineWidth(1)
    end

    if currentPath then
        for i, wp in ipairs(currentPath) do
            if i == 1 then
                love.graphics.setColor(0, 1, 0.3, 1)
            else
                love.graphics.setColor(0, 0.5, 1, 0.7)
            end
            love.graphics.circle("fill", wp.x, wp.y, 4)
            love.graphics.setColor(0, 0, 0, 0.8)
            love.graphics.circle("line", wp.x, wp.y, 4)
        end
    end

    if currentPath and #currentPath > 0 then
        local goal = currentPath[#currentPath]
        love.graphics.setColor(1, 0.2, 0, 1)
        love.graphics.circle("fill", goal.x, goal.y, 7)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.circle("fill", goal.x, goal.y, 3)
    end

    if entityState then
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.circle("fill", entityState.x, entityState.y, 5)
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.circle("line", entityState.x, entityState.y, 5)
    end

    if entityState then
        love.graphics.setColor(1, 1, 1, 0.9)
        local status = "no path"
        if currentPath then
            status = "waypoints: " .. #currentPath
        end
        love.graphics.print(status, entityState.x + 10, entityState.y - 20)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return AI