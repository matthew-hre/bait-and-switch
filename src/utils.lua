utils = {}

function utils.lerp(a, b, t)
	return a + (b - a) * t
end

function utils.drawWithShadow(sprite, x, y, angle, sx, sy, ox, oy, shadowOffset, shadowColor, tint)
    -- Default values
    sx = sx or 1
    sy = sy or sx
    angle = angle or 0
    ox = ox or 0
    oy = oy or 0
    shadowOffset = shadowOffset or 3
    shadowColor = shadowColor or {0, 0, 0, 1}
    
    -- Draw shadow
    love.graphics.setColor(shadowColor)
    love.graphics.draw(sprite, x + shadowOffset, y + shadowOffset, angle, sx, sy, ox, oy)
    
    -- Draw main sprite
    if tint then
        love.graphics.setColor(tint)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.draw(sprite, x, y, angle, sx, sy, ox, oy)
end

return utils