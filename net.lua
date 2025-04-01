local net = {}

function net.load(assets, playerRef)
    net.sprite = assets.netSprite
    net.shadowColor = assets.shadowColor

    net.player = playerRef

    net.x = 0
    net.y = 0
    net.angle = 0
    net.scaleY = 1
    net.shadowOffset = 3

    net.followDistance = net.sprite:getWidth()
    net.swinging = false

    net.swingHoldTimer = 0
    net.swingHoldDuration = 0.3
end

function net.update(dt)
    local mx, my = love.mouse.getPosition()
    mx = mx / 4
    my = my / 4
    local angleToMouse = math.atan2(my - net.player.y, mx - net.player.x) + math.pi / 2

    local targetX = net.player.x + math.cos(angleToMouse) * net.followDistance
    local targetY = net.player.y + math.sin(angleToMouse) * net.followDistance

    local ease = 30 * dt
    net.x = net.x + (targetX - net.x) * ease
    net.y = net.y + (targetY - net.y) * ease

    net.angle = angleToMouse

    if net.swinging then
        if net.swingingOut then
            net.scaleY = net.scaleY - 12 * dt
            if net.scaleY <= -1 then
                net.scaleY = -1
                net.swingingOut = false
                net.swingHoldTimer = 0
            end
        elseif net.swingHoldTimer < net.swingHoldDuration then
            net.swingHoldTimer = net.swingHoldTimer + dt
            -- do nothing, hold the frame
        else
            net.scaleY = net.scaleY + 24 * dt
            if net.scaleY >= 1 then
                net.scaleY = 1
                net.swinging = false
            end
        end
    
        net.shadowOffset = math.abs(3 * net.scaleY)
    end
    
end

function net.mousepressed(x, y, button)
    if button == 1 and not net.swinging then
        net.swinging = true
        net.swingingOut = true
    end
end

function net.draw()
    local ox = net.sprite:getWidth() / 2
    local oy = 0 -- top center

    local px = math.floor(net.x)
    local py = math.floor(net.y)
    local drawAngle = net.angle

    love.graphics.setColor(net.shadowColor)
    love.graphics.draw(net.sprite, px + net.shadowOffset, py + net.shadowOffset, drawAngle, 1, net.scaleY, ox, oy)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(net.sprite, px, py, drawAngle, 1, net.scaleY, ox, oy)
end

return net
