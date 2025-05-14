local pauseMenu = {}

local config = require("src.config")
local assets = require("src.assets")
local gameState = require("src.gameState")
local utils = require("src.utils")
local input = require("src.input")

pauseMenu.config = {
    slideSpeed = 15,
    startY = -200,
    exitSpeed = 15,
    popupShadow = { x = 2, y = 2 },
    
    titleScale = 2,
    titlePadding = 20,
    titleWiggle = {
        maxRotation = math.rad(2),
        speed = 3,
    },
    
    statsYOffset = 36,
    statsColumnWidth = 70,
    statsLabelPadding = -2,
    
    buttonPadding = 6,
    buttonHeight = 16,
    buttonYStart = 68,
    buttonHoverOffset = 1,
    buttonTextOffset = 1,
}

function pauseMenu.load()
    pauseMenu.popup = assets.ui.popup
    pauseMenu.shadowColor = assets.shadowColor
    pauseMenu.visible = false
    pauseMenu.isAnimating = false
    pauseMenu.isExiting = false
    pauseMenu.y = pauseMenu.config.startY
    pauseMenu.targetY = 0
    pauseMenu.width = assets.ui.popup:getWidth()
    pauseMenu.height = assets.ui.popup:getHeight()
    
    pauseMenu.wiggleTime = 0
    
    pauseMenu.buttons = {
        { text = "Resume", action = function() pauseMenu.hide() end },
        { text = "Settings", action = function() pauseMenu.showSettings() end },
        { text = "Quit", action = function() love.event.quit() end }
    }
    pauseMenu.hoveredButton = nil
end

function pauseMenu.show()
    if pauseMenu.visible then return end
    
    pauseMenu.visible = true
    pauseMenu.isAnimating = true
    pauseMenu.isExiting = false
    pauseMenu.y = pauseMenu.config.startY
    
    pauseMenu.targetY = (config.screen.height - pauseMenu.height) / 2
    
    gameState.paused = true
    gameState.pausedForPause = true
    
    pauseMenu.hoveredButton = nil
end

function pauseMenu.hide()
    pauseMenu.isExiting = true
    pauseMenu.isAnimating = true

    pauseMenu.targetY = pauseMenu.config.startY
end

function pauseMenu.showSettings()
    print("Settings menu would go here")
end

function pauseMenu.update(dt)
    if not pauseMenu.visible then return end
    
    pauseMenu.wiggleTime = pauseMenu.wiggleTime + dt * pauseMenu.config.titleWiggle.speed
    
    if pauseMenu.isAnimating then
        local speed = pauseMenu.isExiting and pauseMenu.config.exitSpeed or pauseMenu.config.slideSpeed
        pauseMenu.y = utils.lerp(pauseMenu.y, pauseMenu.targetY, dt * speed)
        
        if pauseMenu.isExiting then
            if pauseMenu.y <= pauseMenu.config.startY + 10 then
                pauseMenu.visible = false
                pauseMenu.isAnimating = false
                pauseMenu.isExiting = false
                pauseMenu.y = pauseMenu.config.startY
                
                gameState.paused = false
                gameState.pausedForPause = false
            end
        else
            if math.abs(pauseMenu.y - pauseMenu.targetY) < 1 then
                pauseMenu.y = pauseMenu.targetY
                pauseMenu.isAnimating = false
            end
        end
    end
    
    if not pauseMenu.isAnimating and not pauseMenu.isExiting then
        local scaledX, scaledY = input.getMousePosition()
        
        local popupX = (config.screen.width - pauseMenu.width) / 2
        local popupY = pauseMenu.y
        
        pauseMenu.hoveredButton = nil
        
        for i, button in ipairs(pauseMenu.buttons) do
            local buttonY = popupY + pauseMenu.config.buttonYStart + (i-1) * pauseMenu.config.buttonHeight
            
            if scaledX >= popupX + pauseMenu.config.buttonPadding and
               scaledX <= popupX + pauseMenu.width - pauseMenu.config.buttonPadding and
               scaledY >= buttonY and
               scaledY <= buttonY + pauseMenu.config.buttonHeight then
                pauseMenu.hoveredButton = i
                break
            end
        end
    end
end

function pauseMenu.draw()
    if not pauseMenu.visible then return end
    
    local popupX = (config.screen.width - pauseMenu.width) / 2
    local popupY = pauseMenu.y
    
    love.graphics.setColor(pauseMenu.shadowColor)
    love.graphics.draw(pauseMenu.popup, popupX + pauseMenu.config.popupShadow.x, popupY + pauseMenu.config.popupShadow.y)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(pauseMenu.popup, popupX, popupY)
    
    if not pauseMenu.isExiting then
        local titleX = popupX + pauseMenu.width / 2
        local titleY = popupY + pauseMenu.config.titlePadding
        local titleRotation = math.sin(pauseMenu.wiggleTime) * pauseMenu.config.titleWiggle.maxRotation
        
        love.graphics.setFont(assets.fonts.fat)
        
        local titleText = "PAUSED"
        local titleWidth = assets.fonts.fat:getWidth(titleText) * pauseMenu.config.titleScale
        local titleHeight = assets.fonts.fat:getHeight() * pauseMenu.config.titleScale
        
        love.graphics.setColor(pauseMenu.shadowColor)
        love.graphics.push()
        love.graphics.translate(titleX + 3, titleY + 3)
        love.graphics.rotate(titleRotation)
        love.graphics.scale(pauseMenu.config.titleScale)
        love.graphics.print(titleText, -assets.fonts.fat:getWidth(titleText)/2, -assets.fonts.fat:getHeight()/2)
        love.graphics.pop()
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.push()
        love.graphics.translate(titleX, titleY)
        love.graphics.rotate(titleRotation)
        love.graphics.scale(pauseMenu.config.titleScale)
        love.graphics.print(titleText, -assets.fonts.fat:getWidth(titleText)/2, -assets.fonts.fat:getHeight()/2)
        love.graphics.pop()
        
        love.graphics.setFont(assets.fonts.m5x7)
        
        local statsY = popupY + pauseMenu.config.statsYOffset
        local col1X = popupX + pauseMenu.width/6
        local col2X = popupX + pauseMenu.width/2
        local col3X = popupX + pauseMenu.width*5/6
        
        love.graphics.setColor(pauseMenu.shadowColor)
        love.graphics.printf("WAVE", col1X - pauseMenu.config.statsColumnWidth/2 + 1, statsY + 1, pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("WAVE", col1X - pauseMenu.config.statsColumnWidth/2, statsY, pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setFont(assets.fonts.fat)
        
        love.graphics.setColor(pauseMenu.shadowColor)
        love.graphics.printf(tostring(gameState.stats.currentWave), col1X - pauseMenu.config.statsColumnWidth/2 + 1, 
                          statsY + assets.fonts.m5x7:getHeight() + pauseMenu.config.statsLabelPadding + 1, 
                          pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(tostring(gameState.stats.currentWave), col1X - pauseMenu.config.statsColumnWidth/2, 
                          statsY + assets.fonts.m5x7:getHeight() + pauseMenu.config.statsLabelPadding, 
                          pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setFont(assets.fonts.m5x7)
        
        love.graphics.setColor(pauseMenu.shadowColor)
        love.graphics.printf("BEST", col2X - pauseMenu.config.statsColumnWidth/2 + 1, statsY + 1, pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("BEST", col2X - pauseMenu.config.statsColumnWidth/2, statsY, pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setFont(assets.fonts.fat)
        
        love.graphics.setColor(pauseMenu.shadowColor)
        love.graphics.printf(tostring(gameState.deathScreen.bestWave), col2X - pauseMenu.config.statsColumnWidth/2 + 1, 
                          statsY + assets.fonts.m5x7:getHeight() + pauseMenu.config.statsLabelPadding + 1, 
                          pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(tostring(gameState.deathScreen.bestWave), col2X - pauseMenu.config.statsColumnWidth/2, 
                          statsY + assets.fonts.m5x7:getHeight() + pauseMenu.config.statsLabelPadding, 
                          pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setFont(assets.fonts.m5x7)
        
        love.graphics.setColor(pauseMenu.shadowColor)
        love.graphics.printf("KILLS", col3X - pauseMenu.config.statsColumnWidth/2 + 1, statsY + 1, pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("KILLS", col3X - pauseMenu.config.statsColumnWidth/2, statsY, pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setFont(assets.fonts.fat)
        
        love.graphics.setColor(pauseMenu.shadowColor)
        love.graphics.printf(tostring(gameState.stats.killCount), col3X - pauseMenu.config.statsColumnWidth/2 + 1, 
                          statsY + assets.fonts.m5x7:getHeight() + pauseMenu.config.statsLabelPadding + 1, 
                          pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(tostring(gameState.stats.killCount), col3X - pauseMenu.config.statsColumnWidth/2, 
                          statsY + assets.fonts.m5x7:getHeight() + pauseMenu.config.statsLabelPadding, 
                          pauseMenu.config.statsColumnWidth, "center")
        
        love.graphics.setFont(assets.fonts.fat)
        for i, button in ipairs(pauseMenu.buttons) do
            local buttonY = popupY + pauseMenu.config.buttonYStart + (i-1) * pauseMenu.config.buttonHeight
            local isHovered = pauseMenu.hoveredButton == i
            
            local textYOffset = isHovered and -pauseMenu.config.buttonHoverOffset or 0
            
            if isHovered then
                love.graphics.setColor(pauseMenu.shadowColor)
                love.graphics.printf(button.text, 
                                    popupX + pauseMenu.config.buttonTextOffset, 
                                    buttonY + pauseMenu.config.buttonTextOffset + textYOffset, 
                                    pauseMenu.width, "center")
            end
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(button.text, 
                                popupX, 
                                buttonY + textYOffset, 
                                pauseMenu.width, "center")
        end
    end
end

function pauseMenu.mousepressed(x, y, button)
    if not pauseMenu.visible or pauseMenu.isAnimating or pauseMenu.isExiting then 
        return false
    end
    
    if pauseMenu.hoveredButton then
        local action = pauseMenu.buttons[pauseMenu.hoveredButton].action
        if action then
            action()
        end
        return true
    end
    
    return false
end

function pauseMenu.toggle()
    if pauseMenu.visible then
        pauseMenu.hide()
    else
        pauseMenu.show()
    end
end

return pauseMenu