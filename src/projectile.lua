local projectile = {}

local config = require("src.config")
local assets = require("src.assets")
local particle = require("src.particle")
local enemy = require("src.enemy")
local gameState = require("src.gameState")
local utils = require("src.utils")

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
    bounceDamping = 0.99,

    splitCount = 0,
    splitSizeMultiplier = 0.5
}

projectile.active = {}

function projectile.load()
    projectile.sprite = assets.enemySprite
    projectile.shadowColor = assets.shadowColor
    
    projectile.screenWidth = config.screen.width
    projectile.screenHeight = config.screen.height
    projectile.shadowOffset = config.visual.shadowOffset
    
    projectile.spriteWidth = projectile.sprite:getWidth()
    projectile.spriteHeight = projectile.sprite:getHeight()
    projectile.spriteOX = projectile.spriteWidth / 2
    projectile.spriteOY = projectile.spriteHeight / 2
    
    projectile.size = 1
    projectile.color = assets.enemyColor
    projectile.enemyShadowColor = assets.enemyShadowColor
end

function projectile.create(x, y, targetX, targetY, options)
    options = options or {}
    local p = {}
    p.x = x
    p.y = y
    p.particleTimer = 0 

    p.angle = math.atan2(targetY - y, targetX - x)

    local speed = projectile.config.speed
    p.vx = math.cos(p.angle) * speed
    p.vy = math.sin(p.angle) * speed
    
    p.hitEnemies = {}
    
    if options.bounces ~= nil then
        p.bouncesRemaining = options.bounces
    elseif options.noBounce then
        p.bouncesRemaining = 0
    else
        p.bouncesRemaining = projectile.config.maxBounces
    end
    p.scale = options.scale or projectile.size
    p.canSplit = not options.noSplit

    table.insert(projectile.active, p)
    return p
end

function projectile.clearAllBounces()
    for _, p in ipairs(projectile.active) do
        p.bouncesRemaining = 0
    end
end

function projectile.update(dt)
    if gameState.isPaused() then
        return
    end
    
    local sqrt = math.sqrt
    local random = math.random
    local atan2 = math.atan2
    local cos = math.cos
    local sin = math.sin
    local checkEnemyCollision = projectile.checkEnemyCollision
    
    local n = #projectile.active
    local i = 1
    while i <= n do
        local p = projectile.active[i]
        
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        
        p.particleTimer = p.particleTimer + dt
        
        if p.particleTimer >= projectile.config.particleDelay then

            local scale = random() * 
                (projectile.config.particle.maxScale - projectile.config.particle.minScale) + 
                projectile.config.particle.minScale

            local scaleDecay = random() *
                (projectile.config.particle.maxScaleDecay - projectile.config.particle.minScaleDecay) + 
                projectile.config.particle.minScaleDecay

            local rotation = (random() * 2 - 1) * projectile.config.particle.maxRotationSpeed
            local vx = (random() * 2 - 1) * projectile.config.particle.maxVelocity
            local vy = (random() * 2 - 1) * projectile.config.particle.maxVelocity

            local particleOptions = {
                scale = scale,
                scaleDecay = scaleDecay,
                rotation = rotation,
                vx = vx,
                vy = vy,
                shadowOffset = projectile.shadowOffset
            }

            particleOptions.color = projectile.color
            particleOptions.shadowColor = projectile.enemyShadowColor
            particle.create(p.x, p.y, projectile.sprite, particleOptions)
            
            p.particleTimer = 0
        end
        
        checkEnemyCollision(p)
        projectile.checkSpeedyBugCollision(p)
        n = #projectile.active
        
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
            p.angle = atan2(p.vy, p.vx)
            assets.playSound(assets.audio.bounce, 0.1)
        end
        
        if p.dead or
           p.x < -margin or p.x > projectile.screenWidth + margin or
           p.y < -margin or p.y > projectile.screenHeight + margin then
            projectile.active[i] = projectile.active[n]
            projectile.active[n] = nil
            n = n - 1
        else
            i = i + 1
        end
    end
end

function projectile.checkEnemyCollision(proj)
    local sqrt = math.sqrt
    local ipairs = ipairs
    local collisionRadius = projectile.config.collisionRadius
    local hitAny = false
    
    for _, e in ipairs(enemy.active) do
        if not e.caught and not e.dead and not proj.hitEnemies[e] then
            local dx = proj.x - e.x
            local dy = proj.y - e.y
            local distance = sqrt(dx * dx + dy * dy)
            
            if distance < collisionRadius then
                proj.hitEnemies[e] = true
                hitAny = true
                
                enemy.kill(e)
            end
        end
    end

    if hitAny and proj.canSplit and not proj.hasSplit and projectile.config.splitCount > 0 then
        proj.hasSplit = true
        proj.dead = true
        for i = 1, projectile.config.splitCount do
            local spread = (math.random() * 2 - 1) * math.rad(40)
            local splitAngle = proj.angle + spread
            local splitTargetX = proj.x + math.cos(splitAngle) * 100
            local splitTargetY = proj.y + math.sin(splitAngle) * 100
            projectile.create(proj.x, proj.y, splitTargetX, splitTargetY, {
                bounces = proj.bouncesRemaining,
                noSplit = true,
                scale = projectile.size * projectile.config.splitSizeMultiplier
            })
        end
        assets.playSound(assets.audio.bounce, 0.1)
    end
end

function projectile.checkSpeedyBugCollision(proj)
    local speedyBug = require("src.speedyBug")
    local sqrt = math.sqrt
    local collisionRadius = projectile.config.collisionRadius
    
    for _, b in ipairs(speedyBug.active) do
        if not proj.hitEnemies[b] then
            local dx = proj.x - b.x
            local dy = proj.y - b.y
            local distance = sqrt(dx * dx + dy * dy)
            
            if distance < collisionRadius then
                proj.hitEnemies[b] = true
                
                -- reflect projectile velocity off the speedy bug
                local len = sqrt(dx * dx + dy * dy)
                if len > 0 then
                    local nx, ny = dx / len, dy / len
                    local dot = proj.vx * nx + proj.vy * ny
                    proj.vx = proj.vx - 2 * dot * nx
                    proj.vy = proj.vy - 2 * dot * ny
                    proj.angle = math.atan2(proj.vy, proj.vx)
                end
                
                assets.playSound(assets.audio.bounce, 0.1)
            end
        end
    end
end

function projectile.draw()
    local floor = math.floor
    local sprite = projectile.sprite
    local ox = projectile.spriteOX
    local oy = projectile.spriteOY
    local shadowOffset = projectile.shadowOffset
    local shadowColor = projectile.enemyShadowColor
    local pi = math.pi
    local scale = projectile.size or 1
    
    local tint = projectile.color
    
    for _, p in ipairs(projectile.active) do
        local drawAngle = p.angle + pi/2
        local s = p.scale or scale
        utils.drawWithShadow(sprite, floor(p.x), floor(p.y), drawAngle, s, s, ox, oy, shadowOffset, shadowColor, tint)
    end
end

return projectile
