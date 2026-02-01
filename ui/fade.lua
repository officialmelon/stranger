local Fade = {}
local _alpha = 0
local _target = 0
local _speed = 1.5
local _callback = nil

function Fade.Out(callback, speed)
    _alpha = 0
    _target = 1
    _speed = speed or 1.5
    _callback = callback
end

function Fade.In(speed)
    _alpha = 1
    _target = 0
    _speed = speed or 1.5
    _callback = nil
end

function Fade.isActive()
    return _alpha > 0
end

function Fade.update(dt)
    if _alpha == _target then return end
    local dir = _target > _alpha and 1 or -1
    _alpha = _alpha + dir * (dt / _speed)
    if dir == 1 and _alpha >= _target then
        _alpha = _target
        if _callback then
            local cb = _callback
            _callback = nil
            cb()
        end
    elseif dir == -1 and _alpha <= _target then
        _alpha = _target
    end
end

function Fade.draw()
    if _alpha <= 0 then return end
    love.graphics.setColor(0, 0, 0, _alpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
end

return Fade