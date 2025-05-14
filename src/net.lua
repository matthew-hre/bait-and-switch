local net = {}

local config = require("src.config")
local assets = require("src.assets")
local playerRef = require("src.player")
local input = require("src.input")
local utils = require("src.utils")

local projectile = require("src.projectile")
local gameState = require("src.gameState")

net.config = {
    swingOutSpeed = 20,
    swingInSpeed = 16,
    swingHoldDuration = 0.3,
    
    followDistance = 16,
    collisionRadius = 12,
    
    mouseScale = 4,

    ease = 40
}

function net.load()
    net.sprite = assets.netSprite
    net.loadedSprite = assets.netLoadedSprite
    net.shadowColor = assets.shadowColor

    net.player = playerRef

    net.x = config.screen.width / 2
    net.y = config.screen.height / 2 -- kinda centered
    net.angle = 0
    net.scaleY = 1

    net.shadowOffset = config.visual.shadowOffset
    net.mouseScale = config.screen.scale
    
    net.config.followDistance = net.sprite:getWidth()
    
    net.swinging = false
    net.loaded = false
    net.swingingOut = false

    net.swingHoldTimer = 0
        
    net.visible = true
end

function net.update(dt)
    local mx, my = input.getMousePosition()
    local angleToMouse = math.atan2(my - net.player.y, mx - net.player.x) + math.pi / 2

    local positioningAngle
    if gameState.settings.netPosition == "right" then
        positioningAngle = angleToMouse
    else
        -- default to left side
        positioningAngle = angleToMouse + math.pi
    end
    
    local targetX = net.player.x + math.cos(positioningAngle) * net.config.followDistance
    local targetY = net.player.y + math.sin(positioningAngle) * net.config.followDistance

    local ease = net.config.ease * dt
    net.x = net.x + (targetX - net.x) * ease
    net.y = net.y + (targetY - net.y) * ease

    net.angle = math.atan2(my - net.y, mx - net.x) + math.pi / 2

    if net.swinging then
        if net.swingingOut then
            net.scaleY = net.scaleY - net.config.swingOutSpeed * dt
            if net.scaleY <= -1 then
                net.scaleY = -1
                net.swingingOut = false
                net.swingHoldTimer = 0
                
                local mx, my = input.getMousePosition()
                
                if net.loaded then
                    local netTipX = net.x + math.sin(net.angle) * net.sprite:getHeight()
                    local netTipY = net.y - math.cos(net.angle) * net.sprite:getHeight()
                    projectile.create(netTipX, netTipY, mx, my)

                    net.loaded = false
                else
                    net.checkEnemyCollision()
                end
            end
        elseif net.swingHoldTimer < net.config.swingHoldDuration then
            net.swingHoldTimer = net.swingHoldTimer + dt
            -- do nothing, hold the frame
        else
            net.scaleY = net.scaleY + net.config.swingInSpeed * dt
            if net.scaleY >= 1 then
                net.scaleY = 1
                net.swinging = false
            end
        end
    
        net.shadowOffset = math.abs(3 * net.scaleY)
    end
end

function net.mousepressed(x, y, button)
    if button == input.actions.net and not net.swinging then
        net.swinging = true
        net.swingingOut = true
    end
end

function net.checkEnemyCollision()
    local enemy = require("src.enemy")
    
    local netTipX = net.x + math.sin(net.angle) * net.sprite:getHeight()
    local netTipY = net.y - math.cos(net.angle) * net.sprite:getHeight()
    
    for i, e in ipairs(enemy.active) do
        if not e.caught then
            local dx = netTipX - e.x
            local dy = netTipY - e.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < net.config.collisionRadius then
                e.caught = true
                net.loaded = true
                return
            end
        end
    end
end

function net.draw()
    if not net.visible then
        return
    end
    
    local ox = net.sprite:getWidth() / 2
    local oy = 0 -- top center

    local px = math.floor(net.x)
    local py = math.floor(net.y)
    local drawAngle = net.angle
    
    local currentSprite = net.loaded and net.loadedSprite or net.sprite

    utils.drawWithShadow(currentSprite, px, py, drawAngle, 1, net.scaleY, ox, oy, net.shadowOffset, net.shadowColor)
end

return net
