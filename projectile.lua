local projectile = {}

local particle = require("particle")

projectile.active = {}

function projectile.load(assets)
    projectile.sprite = assets.enemySprite
    projectile.shadowColor = assets.shadowColor
    projectile.speed = 350
    projectile.particleDelay = 0.02
end

function projectile.create(x, y, targetX, targetY)
    local p = {}
    p.x = x
    p.y = y
    p.particleTimer = 0 

    p.angle = math.atan2(targetY - y, targetX - x)
    
    p.vx = math.cos(p.angle) * projectile.speed
    p.vy = math.sin(p.angle) * projectile.speed
    
    table.insert(projectile.active, p)
    return p
end

function projectile.update(dt)
    for i = #projectile.active, 1, -1 do
        local p = projectile.active[i]
        
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        
        p.particleTimer = p.particleTimer + dt
        
        if p.particleTimer >= projectile.particleDelay then
            local particleOptions = {
                scale = math.random() * 0.5 + 0.2,
                scaleDecay = math.random() * 0.9 + 0.5,
                angle = math.random() * math.pi * 2,
                rotation = (math.random() * 2 - 1) * 3,
                vx = (math.random() * 2 - 1) * 20,
                vy = (math.random() * 2 - 1) * 20
            }
            particle.create(p.x, p.y, projectile.sprite, particleOptions)
            
            p.particleTimer = 0
        end
        
        local screenWidth = love.graphics.getWidth() / 4
        local screenHeight = love.graphics.getHeight() / 4
        local margin = 20
        
        if p.x < -margin or p.x > screenWidth + margin or
           p.y < -margin or p.y > screenHeight + margin then
            table.remove(projectile.active, i)
        end
    end
end

function projectile.draw()
    for _, p in ipairs(projectile.active) do
        local px = math.floor(p.x)
        local py = math.floor(p.y)
        local ox = projectile.sprite:getWidth() / 2
        local oy = projectile.sprite:getHeight() / 2
        
        local drawAngle = p.angle + math.pi/2
        
        love.graphics.setColor(projectile.shadowColor)
        love.graphics.draw(projectile.sprite, px + 3, py + 3, drawAngle, 1, 1, ox, oy)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(projectile.sprite, px, py, drawAngle, 1, 1, ox, oy)
    end
end

return projectile
