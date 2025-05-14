local tutorial = {}

local assets = require("src.assets")
local player = require("src.player")
local enemy = require("src.enemy")
local gameState = require("src.gameState")
local config = require("src.config")
local input = require("src.input")

tutorial.config = {
    walkIconOffset = -32,
    clickIconOffset = 12,
    clickIconYAlign = 0.5,
    fadeSpeed = 5,
    bugYOffset = -64
}

function tutorial.load()
    tutorial.active = true
    
    local bugX = player.x
    local bugY = player.y + tutorial.config.bugYOffset
    
    tutorial.elements = {
        walk = {
            active = true,
            alpha = 1,
            icon = assets.ui.tutorial.walk,
            x = player.x - assets.ui.tutorial.walk:getWidth() / 2,
            y = player.y + tutorial.config.walkIconOffset,
            fadingOut = false
        },
        
        click = {
            active = true,
            alpha = 1,
            icon = assets.ui.tutorial.click,
            x = bugX + tutorial.config.clickIconOffset,
            y = bugY - assets.ui.tutorial.click:getHeight() * tutorial.config.clickIconYAlign,
            fadingOut = false
        }
    }
    
    tutorial.createTutorialBug(bugX, bugY)
    
    gameState.tutorialMode = true
    
    tutorial.shadowOffset = config.visual.shadowOffset
    tutorial.shadowColor = config.visual.shadowColor
end

function tutorial.createTutorialBug(x, y)
    tutorial.tutorialBug = {
        x = x,
        y = y,
        angle = 0,
        caught = false,
        isTutorialBug = true,
        dead = false
    }
    
    table.insert(enemy.active, tutorial.tutorialBug)
end

function tutorial.checkMovement()
    return input.isMovementDown("up") or 
           input.isMovementDown("down") or 
           input.isMovementDown("left") or 
           input.isMovementDown("right")
end

function tutorial.updateElement(element, dt, condition)
    if not element.active then
        return
    end
    
    if condition and not element.fadingOut then
        element.fadingOut = true
    end
    
    if element.fadingOut then
        element.alpha = element.alpha - dt * tutorial.config.fadeSpeed
        if element.alpha <= 0 then
            element.active = false
            element.alpha = 0
        end
    end
end

function tutorial.drawElement(element)
    if not element.active or element.alpha <= 0 then
        return
    end
    
    love.graphics.setColor(tutorial.shadowColor[1], tutorial.shadowColor[2], tutorial.shadowColor[3], element.alpha)
    love.graphics.draw(
        element.icon, 
        math.floor(element.x + tutorial.shadowOffset), 
        math.floor(element.y + tutorial.shadowOffset)
    )
    
    love.graphics.setColor(1, 1, 1, element.alpha)
    love.graphics.draw(
        element.icon, 
        math.floor(element.x), 
        math.floor(element.y)
    )
end

function tutorial.update(dt)
    if not tutorial.active then
        return
    end
    
    if tutorial.tutorialBug and not tutorial.tutorialBug.caught then
        tutorial.tutorialBug.angle = tutorial.tutorialBug.angle + enemy.config.spinSpeed * dt
    end
    
    tutorial.updateElement(tutorial.elements.walk, dt, tutorial.checkMovement())
    tutorial.updateElement(tutorial.elements.click, dt, input.isActionDown("net"))
    
    if tutorial.tutorialBug and tutorial.tutorialBug.caught then
        tutorial.active = false
        gameState.tutorialMode = false
    end
end

function tutorial.draw()
    if not tutorial.active then
        return
    end
    
    tutorial.drawElement(tutorial.elements.walk)
    tutorial.drawElement(tutorial.elements.click)
    
    love.graphics.setColor(1, 1, 1, 1)
end

return tutorial