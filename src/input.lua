local input = {}

local config = require("src.config")

input.buttonsDown = {}
input.buttonsPressed = {}
input.buttonsReleased = {}

input.mouse = {
    x = 0,
    y = 0,
    scaledX = 0,
    scaledY = 0
}

input.actions = {
    net = 1,
    pause = "escape"
}

function input.load()
    input.movements = config.controls.movement
    input.actions.net = config.controls.action.net
    input.screenScale = config.screen.scale
end

function input.update()    
    input.mouse.x, input.mouse.y = love.mouse.getPosition()
    input.mouse.scaledX = input.mouse.x / input.screenScale
    input.mouse.scaledY = input.mouse.y / input.screenScale
end

function input.clear()
    input.buttonsPressed = {}
    input.buttonsReleased = {}
end

function input.isMovementDown(direction)
    if not input.movements[direction] then
        return false
    end
    
    for _, key in ipairs(input.movements[direction]) do
        if love.keyboard.isDown(key) then
            return true
        end
    end
    
    return false
end

function input.getMovementVector()
    local dx, dy = 0, 0
    
    if input.isMovementDown("up") then dy = dy - 1 end
    if input.isMovementDown("down") then dy = dy + 1 end
    if input.isMovementDown("left") then dx = dx - 1 end
    if input.isMovementDown("right") then dx = dx + 1 end
    
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx, dy = dx / len, dy / len
    end
    
    return dx, dy
end

function input.isActionDown(action)
    local key = input.actions[action]
    if type(key) == "number" then
        return love.mouse.isDown(key)
    elseif type(key) == "string" then
        return love.keyboard.isDown(key)
    end
    return false
end

function input.isActionPressed(action)
    return input.buttonsPressed[input.actions[action]] or false
end

function input.isActionReleased(action)
    return input.buttonsReleased[input.actions[action]] or false
end

function input.getMousePosition()
    return input.mouse.scaledX, input.mouse.scaledY
end

function input.getRawMousePosition()
    return input.mouse.x, input.mouse.y
end

function input.keypressed(key)
    input.buttonsDown[key] = true
    input.buttonsPressed[key] = true
end

function input.keyreleased(key)
    input.buttonsDown[key] = nil
    input.buttonsReleased[key] = true
end

function input.mousepressed(x, y, button)
    input.buttonsDown[button] = true
    input.buttonsPressed[button] = true
end

function input.mousereleased(x, y, button)
    input.buttonsDown[button] = nil
    input.buttonsReleased[button] = true
end

return input