local projectile = {}

local particle = require("particle")
local enemy = require("enemy")

projectile.config = {
    speed = 350,
    
    particleDelay = 0.02,
    
    margin = 20,
    
    particle = {
        minScale = 0.2,
        maxScale = 0.7,
        minScaleDecay = 0.5, 
        maxScaleDecay = 1.4,
        maxRotationSpeed = 3,
        maxVelocity = 20
    },
    
    collisionRadius = 12  -- Radius for collision detection with enemies
}

projectile.active = {}

function projectile.load(assets, config)
    projectile.sprite = assets.enemySprite
    projectile.shadowColor = assets.shadowColor
    
    projectile.screenWidth = config.screen.width
    projectile.screenHeight = config.screen.height
    projectile.shadowOffset = config.visual.shadowOffset
end

function projectile.create(x, y, targetX, targetY)
    local p = {}
    p.x = x
    p.y = y
    p.particleTimer = 0 

    p.angle = math.atan2(targetY - y, targetX - x)
    
    p.vx = math.cos(p.angle) * projectile.config.speed
    p.vy = math.sin(p.angle) * projectile.config.speed
    
    -- Add a table to track which enemies this projectile has hit
    p.hitEnemies = {}
    
    table.insert(projectile.active, p)
    return p
end

function projectile.update(dt)
    for i = #projectile.active, 1, -1 do
        local p = projectile.active[i]
        
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        
        p.particleTimer = p.particleTimer + dt
        
        if p.particleTimer >= projectile.config.particleDelay then

            local scale = math.random() * 
                (projectile.config.particle.maxScale - projectile.config.particle.minScale) + 
                projectile.config.particle.minScale

            local scaleDecay = math.random() *
                (projectile.config.particle.maxScaleDecay - projectile.config.particle.minScaleDecay) + 
                projectile.config.particle.minScaleDecay

            local rotation = (math.random() * 2 - 1) * projectile.config.particle.maxRotationSpeed
            local vx = (math.random() * 2 - 1) * projectile.config.particle.maxVelocity
            local vy = (math.random() * 2 - 1) * projectile.config.particle.maxVelocity

            local particleOptions = {
                scale = scale,
                scaleDecay = scaleDecay,
                rotation = rotation,
                vx = vx,
                vy = vy,
                shadowOffset = projectile.shadowOffset
            }

            particle.create(p.x, p.y, projectile.sprite, particleOptions)
            
            p.particleTimer = 0
        end
        
        -- Check for enemy collisions but don't destroy the projectile
        projectile.checkEnemyCollision(p)
        
        -- Only remove if out of bounds
        if p.x < -projectile.config.margin or 
           p.x > projectile.screenWidth + projectile.config.margin or
           p.y < -projectile.config.margin or 
           p.y > projectile.screenHeight + projectile.config.margin then
            table.remove(projectile.active, i)
        end
    end
end

-- Modified function to check collisions without destroying the projectile
function projectile.checkEnemyCollision(proj)
    for i, e in ipairs(enemy.active) do
        -- Skip caught, dead, or already hit enemies
        if not e.caught and not e.dead and not proj.hitEnemies[e] then
            local dx = proj.x - e.x
            local dy = proj.y - e.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < projectile.config.collisionRadius then
                -- Mark this enemy as hit by this projectile
                proj.hitEnemies[e] = true
                
                -- Kill the enemy and generate particles
                enemy.kill(e)
            end
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
        love.graphics.draw(
            projectile.sprite, 
            px + projectile.shadowOffset, 
            py + projectile.shadowOffset, 
            drawAngle, 1, 1, ox, oy
        )
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(projectile.sprite, px, py, drawAngle, 1, 1, ox, oy)
    end
end

return projectile
