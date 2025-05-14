local projectile = {}

local config = require("config")
local assets = require("assets")
local particle = require("particle")
local enemy = require("enemy")
local gameState = require("gameState")

projectile.config = {
    speed = 350,
    
    particleDelay = 0.02,
    
    margin = 2, -- screen edge margin for bouncing
    
    particle = {
        minScale = 0.2,
        maxScale = 0.7,
        minScaleDecay = 0.5, 
        maxScaleDecay = 1.4,
        maxRotationSpeed = 3,
        maxVelocity = 20
    },
    
    collisionRadius = 12,
    
    maxBounces = 0,
    bounceDamping = 0.99
}

projectile.active = {}

function projectile.load()
    projectile.sprite = assets.enemySprite
    projectile.shadowColor = assets.shadowColor
    
    projectile.screenWidth = config.screen.width
    projectile.screenHeight = config.screen.height
    projectile.shadowOffset = config.visual.shadowOffset
    
    projectile.size = 1
end

function projectile.create(x, y, targetX, targetY)
    local p = {}
    p.x = x
    p.y = y
    p.particleTimer = 0 

    p.angle = math.atan2(targetY - y, targetX - x)
    
    p.vx = math.cos(p.angle) * projectile.config.speed
    p.vy = math.sin(p.angle) * projectile.config.speed
    
    p.hitEnemies = {}
    
    p.bouncesRemaining = projectile.config.maxBounces
    
    table.insert(projectile.active, p)
    return p
end

function projectile.clearAllBounces()
    for _, p in ipairs(projectile.active) do
        p.bouncesRemaining = 0
    end
end

function projectile.update(dt)
    if gameState.paused then
        return
    end
    
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
        
        projectile.checkEnemyCollision(p)
        
        local bounced = false
        local margin = projectile.config.margin
        
        if p.x < margin and p.vx < 0 then
            if p.bouncesRemaining > 0 then
                p.vx = -p.vx * projectile.config.bounceDamping
                p.x = margin
                p.bouncesRemaining = p.bouncesRemaining - 1
                bounced = true
            end
        elseif p.x > projectile.screenWidth - margin and p.vx > 0 then
            if p.bouncesRemaining > 0 then
                p.vx = -p.vx * projectile.config.bounceDamping
                p.x = projectile.screenWidth - margin
                p.bouncesRemaining = p.bouncesRemaining - 1
                bounced = true
            end
        end
        
        if p.y < margin and p.vy < 0 then
            if p.bouncesRemaining > 0 then
                p.vy = -p.vy * projectile.config.bounceDamping
                p.y = margin
                p.bouncesRemaining = p.bouncesRemaining - 1
                bounced = true
            end
        elseif p.y > projectile.screenHeight - margin and p.vy > 0 then
            if p.bouncesRemaining > 0 then
                p.vy = -p.vy * projectile.config.bounceDamping
                p.y = projectile.screenHeight - margin
                p.bouncesRemaining = p.bouncesRemaining - 1
                bounced = true
            end
        end
        
        if bounced then
            p.angle = math.atan2(p.vy, p.vx)
        end
        
        if p.x < -margin or p.x > projectile.screenWidth + margin or
           p.y < -margin or p.y > projectile.screenHeight + margin then
            table.remove(projectile.active, i)
        end
    end
end

function projectile.checkEnemyCollision(proj)
    for i, e in ipairs(enemy.active) do
        if not e.caught and not e.dead and not proj.hitEnemies[e] then
            local dx = proj.x - e.x
            local dy = proj.y - e.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < projectile.config.collisionRadius then
                proj.hitEnemies[e] = true
                
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
        local scale = projectile.size or 1
        
        love.graphics.setColor(projectile.shadowColor)
        love.graphics.draw(
            projectile.sprite, 
            px + projectile.shadowOffset, 
            py + projectile.shadowOffset, 
            drawAngle, scale, scale, ox, oy
        )
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            projectile.sprite, px, py, drawAngle, scale, scale, ox, oy
        )
    end
end

return projectile
