local player = {}

function player.load(assets)
    player.sprite = assets.playerSprite
    player.shadowColor = assets.shadowColor
    player.x = 128
    player.y = 96
    player.speed = 80
    player.angle = 0
end

function player.update(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then dx = dx - 1 end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then dx = dx + 1 end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then dy = dy - 1 end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then dy = dy + 1 end

    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx, dy = dx / len, dy / len
    end

    player.x = math.max(0, math.min(256, player.x + dx * player.speed * dt))
    player.y = math.max(0, math.min(192, player.y + dy * player.speed * dt))

    player.angle = player.angle + 2 * dt
end

function player.draw()
    local px = math.floor(player.x)
    local py = math.floor(player.y)
    local ox = player.sprite:getWidth() / 2
    local oy = player.sprite:getHeight() / 2
    local angle = math.floor(player.angle * 16) / 16

    love.graphics.setColor(player.shadowColor)
    love.graphics.draw(player.sprite, px + 3, py + 3, angle, 1, 1, ox, oy)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(player.sprite, px, py, angle, 1, 1, ox, oy)
end

return player
