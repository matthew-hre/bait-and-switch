local upgradeMenu = {}

local config = require("config")
local assets = require("assets")
local gameState = require("gameState")
local utils = require("utils")

upgradeMenu.config = {
    slideSpeed = 5,
    startY = -200,
    exitSpeed = 7,
}

function upgradeMenu.load()
    upgradeMenu.popup = assets.ui.popup
    upgradeMenu.shadowColor = assets.shadowColor
    upgradeMenu.visible = false
    upgradeMenu.isAnimating = false
    upgradeMenu.isExiting = false
    upgradeMenu.y = upgradeMenu.config.startY
    upgradeMenu.targetY = 0 -- will be calculated when shown
    upgradeMenu.width = assets.ui.popup:getWidth()
    upgradeMenu.height = assets.ui.popup:getHeight()
end

function upgradeMenu.show()
    if upgradeMenu.visible then return end
    
    upgradeMenu.visible = true
    upgradeMenu.isAnimating = true
    upgradeMenu.isExiting = false
    upgradeMenu.y = upgradeMenu.config.startY
    
    upgradeMenu.targetY = (config.screen.height - upgradeMenu.height) / 2
    
    gameState.paused = true
    gameState.pausedForUpgrade = true
end

function upgradeMenu.hide()
    upgradeMenu.isExiting = true
    upgradeMenu.isAnimating = true

    upgradeMenu.targetY = upgradeMenu.config.startY
end

function upgradeMenu.update(dt)
    if not upgradeMenu.visible then return end
    
    if upgradeMenu.isAnimating then
        local speed = upgradeMenu.isExiting and upgradeMenu.config.exitSpeed or upgradeMenu.config.slideSpeed
        upgradeMenu.y = utils.lerp(upgradeMenu.y, upgradeMenu.targetY, dt * speed)
        
        if upgradeMenu.isExiting then
            if upgradeMenu.y <= upgradeMenu.config.startY + 10 then
                upgradeMenu.visible = false
                upgradeMenu.isAnimating = false
                upgradeMenu.isExiting = false
                upgradeMenu.y = upgradeMenu.config.startY
                
                gameState.paused = false
                gameState.pausedForUpgrade = false
            end
        else
            if math.abs(upgradeMenu.y - upgradeMenu.targetY) < 1 then
                upgradeMenu.y = upgradeMenu.targetY
                upgradeMenu.isAnimating = false
            end
        end
    end
end

function upgradeMenu.draw()
    if not upgradeMenu.visible then return end
    
    local popupX = (config.screen.width - upgradeMenu.width) / 2
    local popupY = upgradeMenu.y
    
    love.graphics.setColor(upgradeMenu.shadowColor)
    love.graphics.draw(upgradeMenu.popup, popupX + 2, popupY + 2)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(upgradeMenu.popup, popupX, popupY)
    
    if not upgradeMenu.isExiting then
        love.graphics.setColor(1, 1, 1)
        local text = "Wave " .. (gameState.stats.currentWave - 1) .. " Complete!"
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        love.graphics.print(text, (config.screen.width - textWidth) / 2, popupY + 20)
        
        local clickText = "Click to continue"
        local clickTextWidth = font:getWidth(clickText)
        love.graphics.print(clickText, (config.screen.width - clickTextWidth) / 2, popupY + upgradeMenu.height - 30)
    end
end

function upgradeMenu.mousepressed(x, y, button)
    if not upgradeMenu.visible or upgradeMenu.isAnimating or upgradeMenu.isExiting then 
        return false
    end
    
    local scaledX = x / config.screen.scale
    local scaledY = y / config.screen.scale
    
    local popupX = (config.screen.width - upgradeMenu.width) / 2
    local popupY = upgradeMenu.y
    
    if scaledX >= popupX and 
       scaledX <= popupX + upgradeMenu.width and
       scaledY >= popupY and 
       scaledY <= popupY + upgradeMenu.height then
        
        upgradeMenu.hide()
        return true
    end
    
    return false
end

return upgradeMenu
