local player = {}

local config = require("config")
local assets = require("assets")
local gameState = require("gameState")

player.config = {
    startX = 128,
    startY = 160,
    
    speed = 100,
    spinSpeed = 2,
    
    maxHealth = 3,
    invincibilityDuration = 2,
    flashInterval = 0.1,

    collisionWiggleRoom = 2,
}

function player.load()
    player.sprite = assets.playerSprite
    player.shadowColor = assets.shadowColor
    player.x = player.config.startX
    player.y = player.config.startY
    player.speed = player.config.speed
    player.angle = 0
    
    player.screenWidth = config.screen.width
    player.screenHeight = config.screen.height
    player.shadowOffset = config.visual.shadowOffset
    player.angleSnapFactor = config.visual.angleSnapFactor
    
    player.controls = config.controls.movement
    
    player.health = player.config.maxHealth
    player.isInvincible = false
    player.invincibilityTimer = 0
    player.flashTimer = 0
    player.visible = true
end

function player.update(dt)
    local dx, dy = 0, 0
    
    for _, key in ipairs(player.controls.up) do
        if love.keyboard.isDown(key) then dy = dy - 1 end
    end
    
    for _, key in ipairs(player.controls.down) do
        if love.keyboard.isDown(key) then dy = dy + 1 end
    end
    
    for _, key in ipairs(player.controls.left) do
        if love.keyboard.isDown(key) then dx = dx - 1 end
    end
    
    for _, key in ipairs(player.controls.right) do
        if love.keyboard.isDown(key) then dx = dx + 1 end
    end

    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx, dy = dx / len, dy / len
    end

    player.x = math.max(
        0, 
        math.min(
            player.screenWidth, 
            player.x + dx * player.speed * dt
        )
    )
    
    player.y = math.max(
        0, 
        math.min(
            player.screenHeight, 
            player.y + dy * player.speed * dt
        )
    )

    player.angle = player.angle + player.config.spinSpeed * dt

    if player.isInvincible then
        player.invincibilityTimer = player.invincibilityTimer + dt
        
        player.flashTimer = player.flashTimer + dt
        if player.flashTimer >= player.config.flashInterval then
            player.visible = not player.visible
            player.flashTimer = player.flashTimer - player.config.flashInterval
        end
        
        if player.invincibilityTimer >= player.config.invincibilityDuration then
            player.isInvincible = false
            player.visible = true
            player.invincibilityTimer = 0
        end
    end
end

function player.draw()
    if not player.visible then
        return
    end
    
    local px = math.floor(player.x)
    local py = math.floor(player.y)
    local ox = player.sprite:getWidth() / 2
    local oy = player.sprite:getHeight() / 2
    
    local angle = math.floor(player.angle * player.angleSnapFactor) / player.angleSnapFactor

    love.graphics.setColor(player.shadowColor)
    love.graphics.draw(
        player.sprite, 
        px + player.shadowOffset, 
        py + player.shadowOffset, 
        angle, 1, 1, ox, oy
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(player.sprite, px, py, angle, 1, 1, ox, oy)
end

function player.takeDamage()
    if player.isInvincible then return end
    
    player.health = player.health - 1
    player.isInvincible = true
    player.invincibilityTimer = 0
    player.flashTimer = 0
    player.visible = true
    
    local ui = require("ui")
    ui.setHealth(player.health)
end

function player.getCollisionRadius()
    local width = player.sprite:getWidth()
    
    return math.max(width) / player.config.collisionWiggleRoom
end

return player
