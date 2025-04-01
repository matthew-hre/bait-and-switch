local particle = {}

particle.active = {}

function particle.load(assets)
    particle.shadowColor = assets.shadowColor
end

function particle.create(x, y, sprite, options)
    options = options or {}
    
    local p = {}
    p.x = x
    p.y = y
    p.sprite = sprite
    p.scale = options.scale or 0.5
    p.scaleDecay = options.scaleDecay or 0.5
    p.angle = options.angle or 0
    p.rotation = options.rotation or 0
    p.vx = options.vx or 0
    p.vy = options.vy or 0
    p.shadowOffset = options.shadowOffset or 2
    
    table.insert(particle.active, p)
    return p
end

function particle.update(dt)
    for i = #particle.active, 1, -1 do
        local p = particle.active[i]
        
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        
        if p.rotation ~= 0 then
            p.angle = p.angle + p.rotation * dt
        end
        
        p.scale = p.scale - p.scaleDecay * dt
        
        if p.scale <= 0 then
            table.remove(particle.active, i)
        end
    end
end

function particle.draw()
    for _, p in ipairs(particle.active) do
        local px = math.floor(p.x)
        local py = math.floor(p.y)
        local ox = p.sprite:getWidth() / 2
        local oy = p.sprite:getHeight() / 2
        
        love.graphics.setColor(particle.shadowColor)
        love.graphics.draw(
            p.sprite, 
            px + p.shadowOffset * p.scale, 
            py + p.shadowOffset * p.scale, 
            p.angle, 
            p.scale, 
            p.scale, 
            ox, 
            oy
        )
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            p.sprite, 
            px, 
            py, 
            p.angle, 
            p.scale, 
            p.scale, 
            ox, 
            oy
        )
    end
end

return particle
