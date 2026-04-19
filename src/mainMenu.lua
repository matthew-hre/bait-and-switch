local mainMenu = {}

local config = require("src.config")
local assets = require("src.assets")
local gameState = require("src.gameState")
local utils = require("src.utils")
local input = require("src.input")

mainMenu.config = {
    logoScale = 2,
    logoY = 56,

    buttonHeight = 16,
    buttonY = 120,
    buttonHoverOffset = 1,
    buttonTextOffset = 1,

    fadeInSpeed = 2,
    fadeOutSpeed = 2,
}

function mainMenu.load()
    mainMenu.logo = love.graphics.newImage("assets/logo.png")
    mainMenu.shadowColor = assets.shadowColor
    mainMenu.visible = true
    mainMenu.transitioning = false
    mainMenu.transitionAlpha = 0
    mainMenu.fadingOut = false
    mainMenu.fadeOutAlpha = 0

    mainMenu.buttons = {
        { text = "Play", action = function() mainMenu.beginTransition() end },
        { text = "Settings", action = function() mainMenu.openSettings() end },
        { text = "Quit", action = function() love.event.quit() end },
    }
    mainMenu.hoveredButton = nil
end

function mainMenu.beginTransition()
    mainMenu.transitioning = true
    mainMenu.transitionAlpha = 0
end

function mainMenu.openSettings()
    local settingsMenu = require("src.settingsMenu")
    gameState.pausedForSettings = true
    gameState.paused = true
    settingsMenu.show()
end

function mainMenu.update(dt)
    if not mainMenu.visible then return end

    if mainMenu.transitioning then
        mainMenu.transitionAlpha = mainMenu.transitionAlpha + dt * mainMenu.config.fadeInSpeed
        if mainMenu.transitionAlpha >= 1 then
            mainMenu.transitionAlpha = 0
            mainMenu.visible = false
            mainMenu.transitioning = false
            mainMenu.fadingOut = true
            mainMenu.fadeOutAlpha = 1
            gameState.inMainMenu = false
            gameState.paused = false
        end
        return
    end

    if gameState.pausedForSettings then
        local settingsMenu = require("src.settingsMenu")
        settingsMenu.update(dt)

        if input.isActionPressed("pause") then
            settingsMenu.hide()
        end
        return
    end

    local scaledX, scaledY = input.getMousePosition()

    local previousHovered = mainMenu.hoveredButton
    mainMenu.hoveredButton = nil

    for i, button in ipairs(mainMenu.buttons) do
        local buttonY = mainMenu.config.buttonY + (i - 1) * mainMenu.config.buttonHeight

        if scaledX >= 0 and
            scaledX <= config.screen.width and
            scaledY >= buttonY and
            scaledY <= buttonY + mainMenu.config.buttonHeight then
            mainMenu.hoveredButton = i
            break
        end
    end

    if mainMenu.hoveredButton and mainMenu.hoveredButton ~= previousHovered then
        assets.playSound(assets.audio.uiHover)
    end
end

function mainMenu.draw()
    if not mainMenu.visible then return end

    local logoX = config.screen.width / 2
    local logoY = mainMenu.config.logoY

    utils.drawWithShadow(
        mainMenu.logo,
        logoX,
        logoY,
        0,
        mainMenu.config.logoScale,
        mainMenu.config.logoScale,
        mainMenu.logo:getWidth() / 2,
        mainMenu.logo:getHeight() / 2,
        3,
        mainMenu.shadowColor
    )

    if not gameState.pausedForSettings then
        love.graphics.setFont(assets.fonts.fat)
        for i, button in ipairs(mainMenu.buttons) do
            local buttonY = mainMenu.config.buttonY + (i - 1) * mainMenu.config.buttonHeight
            local isHovered = mainMenu.hoveredButton == i

            local textYOffset = isHovered and -mainMenu.config.buttonHoverOffset or 0

            if isHovered then
                love.graphics.setColor(mainMenu.shadowColor)
                love.graphics.printf(button.text,
                    mainMenu.config.buttonTextOffset,
                    buttonY + mainMenu.config.buttonTextOffset + textYOffset,
                    config.screen.width, "center")
            end

            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(button.text,
                0,
                buttonY + textYOffset,
                config.screen.width, "center")
        end
    end

    if mainMenu.transitioning then
        love.graphics.setColor(1, 1, 1, mainMenu.transitionAlpha)
        love.graphics.draw(assets.bg, 0, 0)
    end
end

function mainMenu.mousepressed(x, y, button)
    if not mainMenu.visible or mainMenu.transitioning then
        return false
    end

    if gameState.pausedForSettings then
        local settingsMenu = require("src.settingsMenu")
        return settingsMenu.mousepressed(x, y, button)
    end

    if mainMenu.hoveredButton then
        assets.playSound(assets.audio.uiClick)
        local action = mainMenu.buttons[mainMenu.hoveredButton].action
        if action then
            action()
        end
        return true
    end

    return false
end

return mainMenu
