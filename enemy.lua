local enemy = {}

local config = require("config")
local assets = require("assets")
local player = require("player")
local particle = require("particle")
local upgradeMenu = require("upgradeMenu")
local gameState = require("gameState")

enemy.config = {
    initialSpawnInterval = 1.5,
    minSpawnInterval = 2.0,
    maxSpawnInterval = 3.0,
    minSpawnCount = 2,
    maxSpawnCount = 3,
    spawnYPosition = -20,
    spawnMargin = 20,
    
    baseSpeed = 40,
    speedVariation = 10,
    spinSpeed = 2,
    
    separationRadius = 15,
    separationStrength = 0.5,

    death = {
        minParticles = 5,
        maxParticles = 8,
        minScale = 0.7,
        maxScale = 1,
        minScaleDecay = 1.4,
        maxScaleDecay = 1.8,
        maxRotationSpeed = 6,
        maxVelocity = 60
    },
}

enemy.active = {}
enemy.spawnTimer = 0
enemy.spawnInterval = enemy.config.initialSpawnInterval

function enemy.load()
    enemy.sprite = assets.enemySprite
    enemy.shadowColor = assets.shadowColor
    
    enemy.screenWidth = config.screen.width
    enemy.screenHeight = config.screen.height
    enemy.shadowOffset = config.visual.shadowOffset
    enemy.angleSnapFactor = config.visual.angleSnapFactor
end

function enemy.createEnemy()
    local e = {}
    e.x = math.random(
        enemy.config.spawnMargin, 
        enemy.screenWidth - enemy.config.spawnMargin
    )
    e.y = enemy.config.spawnYPosition
    e.speed = enemy.config.baseSpeed + math.random(-enemy.config.speedVariation, enemy.config.speedVariation)
    e.angle = 0
    e.caught = false
    e.dead = false
    
    table.insert(enemy.active, e)
    return e
end

function enemy.kill(e)
    if e.dead or e.caught then return end
    
    e.dead = true
    
    gameState.stats.killCount = gameState.stats.killCount + 1
    gameState.stats.waveKills = gameState.stats.waveKills + 1
    
    if gameState.stats.waveKills >= gameState.killsPerWave then
        gameState.stats.waveKills = 0
        gameState.stats.currentWave = gameState.stats.currentWave + 1
        
        upgradeMenu.show()
    end
    
    local particleCount = math.random(
        enemy.config.death.minParticles,
        enemy.config.death.maxParticles
    )
    
    for i = 1, particleCount do
        local scale = math.random() * 
            (enemy.config.death.maxScale - enemy.config.death.minScale) + 
            enemy.config.death.minScale
            
        local scaleDecay = math.random() * 
            (enemy.config.death.maxScaleDecay - enemy.config.death.minScaleDecay) + 
            enemy.config.death.minScaleDecay
            
        local angle = math.random() * math.pi * 2
        local rotation = (math.random() * 2 - 1) * enemy.config.death.maxRotationSpeed
        
        local speed = math.random() * enemy.config.death.maxVelocity
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        
        local whiteSquare = love.graphics.newCanvas(4, 4)
        love.graphics.setCanvas(whiteSquare)
        love.graphics.clear()
        love.graphics.setColor(1, 1, 1) 
        love.graphics.rectangle("fill", 0, 0, 4, 4)
        love.graphics.setCanvas()
        
        local particleOptions = {
            scale = scale,
            scaleDecay = scaleDecay,
            angle = angle,
            rotation = rotation,
            vx = vx,
            vy = vy,
            shadowOffset = enemy.shadowOffset
        }
        
        particle.create(e.x, e.y, whiteSquare, particleOptions)
    end
end

function enemy.calculateSeparation(currentEnemy)
    local separationX, separationY = 0, 0
    local count = 0
    
    for _, e in ipairs(enemy.active) do
        if e ~= currentEnemy and not e.caught then
            local dx = currentEnemy.x - e.x
            local dy = currentEnemy.y - e.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < enemy.config.separationRadius and distance > 0 then
                local strength = 1 - distance / enemy.config.separationRadius
                separationX = separationX + (dx / distance) * strength
                separationY = separationY + (dy / distance) * strength
                count = count + 1
            end
        end
    end
    
    if count > 0 then
        local len = math.sqrt(separationX * separationX + separationY * separationY)
        if len > 0 then
            separationX = separationX / len
            separationY = separationY / len
        end
    end
    
    return separationX, separationY
end

function enemy.checkRotatedRectangleCollision(e, playerX, playerY, playerRadius)
    local enemyWidth = enemy.sprite:getWidth()
    local enemyHeight = enemy.sprite:getHeight()
    
    local halfWidth = enemyWidth / 2
    local halfHeight = enemyHeight / 2
    
    local dx = playerX - e.x
    local dy = playerY - e.y
    
    local angle = -e.angle
    local rotX = dx * math.cos(angle) - dy * math.sin(angle)
    local rotY = dx * math.sin(angle) + dy * math.cos(angle)
    
    local closestX = math.max(-halfWidth, math.min(halfWidth, rotX))
    local closestY = math.max(-halfHeight, math.min(halfHeight, rotY))
    
    local distX = rotX - closestX
    local distY = rotY - closestY
    local distSquared = distX * distX + distY * distY
    
    return distSquared <= (playerRadius * playerRadius)
end

function enemy.update(dt)
    enemy.spawnTimer = enemy.spawnTimer + dt
    
    if enemy.spawnTimer >= enemy.spawnInterval then
        enemy.spawnTimer = 0
        enemy.spawnInterval = math.random() * 
            (enemy.config.maxSpawnInterval - enemy.config.minSpawnInterval) + 
            enemy.config.minSpawnInterval
        
        local spawnCount = math.random(
            enemy.config.minSpawnCount, 
            enemy.config.maxSpawnCount
        )
        
        for i = 1, spawnCount do
            enemy.createEnemy()
        end
    end
    
    for i = #enemy.active, 1, -1 do
        local e = enemy.active[i]
        
        if e.dead then
            table.remove(enemy.active, i)
        elseif not e.caught then
            local dx = player.x - e.x
            local dy = player.y - e.y
            
            local len = math.sqrt(dx * dx + dy * dy)
            
            local playerRadius = player.getCollisionRadius()
            
            -- quick check for collision optimization
            if len < (15 + playerRadius) then
                if enemy.checkRotatedRectangleCollision(e, player.x, player.y, playerRadius) 
                   and not player.isInvincible then
                    player.takeDamage()
                end
            end
            
            if len > 0 then
                dx, dy = dx / len, dy / len
            end
            
            local separationX, separationY = enemy.calculateSeparation(e)
            
            local moveX = dx * (1 - enemy.config.separationStrength) + 
                          separationX * enemy.config.separationStrength
            local moveY = dy * (1 - enemy.config.separationStrength) + 
                          separationY * enemy.config.separationStrength
            
            local moveLen = math.sqrt(moveX * moveX + moveY * moveY)
            if moveLen > 0 then
                moveX = moveX / moveLen
                moveY = moveY / moveLen
            end
            
            e.x = e.x + moveX * e.speed * dt
            e.y = e.y + moveY * e.speed * dt
            
            e.angle = e.angle + enemy.config.spinSpeed * dt
        end
    end
end

function enemy.draw()
    for _, e in ipairs(enemy.active) do
        if not e.caught and not e.dead then
            local px = math.floor(e.x)
            local py = math.floor(e.y)
            local ox = enemy.sprite:getWidth() / 2
            local oy = enemy.sprite:getHeight() / 2
            
            local angle = math.floor(e.angle * enemy.angleSnapFactor) / enemy.angleSnapFactor
            
            love.graphics.setColor(enemy.shadowColor)
            love.graphics.draw(
                enemy.sprite, 
                px + enemy.shadowOffset, 
                py + enemy.shadowOffset, 
                angle, 1, 1, ox, oy
            )
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(enemy.sprite, px, py, angle, 1, 1, ox, oy)
        end
    end
end

return enemy
