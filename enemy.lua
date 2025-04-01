local enemy = {}

local player = require("player")

function enemy.load(assets)
    enemy.sprite = assets.enemySprite
    enemy.shadowColor = assets.shadowColor
    enemy.x = 128
    enemy.y = 20
    enemy.speed = 40
    enemy.angle = 0
    enemy.spinSpeed = 2
    enemy.caught = false  -- Add caught state
end

function enemy.update(dt)
    -- Don't update if caught
    if enemy.caught then
        return
    end

    local dx = player.x - enemy.x
    local dy = player.y - enemy.y

    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx, dy = dx / len, dy / len
    end

    enemy.x = enemy.x + dx * enemy.speed * dt
    enemy.y = enemy.y + dy * enemy.speed * dt

    enemy.angle = enemy.angle + enemy.spinSpeed * dt
end

function enemy.draw()
    -- Don't draw if caught
    if enemy.caught then
        return
    end
    
    local px = math.floor(enemy.x)
    local py = math.floor(enemy.y)
    local ox = enemy.sprite:getWidth() / 2
    local oy = enemy.sprite:getHeight() / 2
    
    local angle = math.floor(enemy.angle * 16) / 16
    
    love.graphics.setColor(enemy.shadowColor)
    love.graphics.draw(enemy.sprite, px + 3, py + 3, angle, 1, 1, ox, oy)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(enemy.sprite, px, py, angle, 1, 1, ox, oy)
end

return enemy
