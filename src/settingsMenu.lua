local settingsMenu = {}

local config = require("src.config")
local assets = require("src.assets")
local gameState = require("src.gameState")
local utils = require("src.utils")
local input = require("src.input")
local save = require("src.save")

local Popup = require("src.ui.popup")

settingsMenu.config = {
    topPadding = 8,
    rowHeight = 16,
    rowPadding = 8,
    sectionSpacing = -4,

    valueWidth = 80,
}

local displayOptions = { "1x", "2x", "3x", "4x", "Full" }
local volumeOptions = { "0%", "10%", "20%", "30%", "40%", "50%", "60%", "70%", "80%", "90%", "100%" }
local handOptions = { "Left", "Right" }

function settingsMenu.load()
    settingsMenu.hoveredRow = nil
    settingsMenu.hoveredArrow = nil -- "left" or "right"

    settingsMenu.settings = {
        windowScale = config.screen.scale,
        fullscreen = false,
        sfxVolume = 5,
        muted = false,
        netPosition = gameState.settings.netPosition or "left",
    }

    settingsMenu.returnState = "MAIN_MENU"

    settingsMenu.popup = Popup.new({
        sprite = assets.ui.popup,
        shadowColor = assets.shadowColor,
        slideSpeed = 12,
        onHideComplete = function()
            settingsMenu.visible = false
            gameState.current = settingsMenu.returnState
        end,
        drawContent = function(popup, x, y)
            settingsMenu.drawContent(x, y)
        end,
    })

    settingsMenu.visible = false

    local data = save.read()
    if data and data.settings then
        if data.settings.windowScale then
            settingsMenu.settings.windowScale = data.settings.windowScale
        end
        if data.settings.fullscreen ~= nil then
            settingsMenu.settings.fullscreen = data.settings.fullscreen
        end
        if data.settings.sfxVolume ~= nil then
            settingsMenu.settings.sfxVolume = data.settings.sfxVolume
        end
        if data.settings.muted ~= nil then
            settingsMenu.settings.muted = data.settings.muted
        end
        if data.settings.netPosition then
            settingsMenu.settings.netPosition = data.settings.netPosition
        end
    end

    settingsMenu.applySettings()
end

function settingsMenu.show(returnState)
    if settingsMenu.popup.visible then return end

    settingsMenu.returnState = returnState or "MAIN_MENU"
    settingsMenu.visible = true
    if returnState == "MAIN_MENU" then
        gameState.current = "MAIN_MENU_SETTINGS"
    else
        gameState.current = "PAUSED_SETTINGS"
    end
    settingsMenu.popup:show()
end

function settingsMenu.hide()
    settingsMenu.saveSettings()
    settingsMenu.popup:hide()
end

function settingsMenu.getDisplayIndex()
    if settingsMenu.settings.fullscreen then
        return 5
    end
    return math.max(1, math.min(4, settingsMenu.settings.windowScale))
end

function settingsMenu.setDisplayFromIndex(idx)
    if idx == 5 then
        settingsMenu.settings.fullscreen = true
    else
        settingsMenu.settings.fullscreen = false
        settingsMenu.settings.windowScale = idx
    end
    settingsMenu.applyDisplay()
end

function settingsMenu.getVolumeIndex()
    if settingsMenu.settings.muted then return 1 end
    return settingsMenu.settings.sfxVolume + 1
end

function settingsMenu.setVolumeFromIndex(idx)
    if idx == 1 then
        settingsMenu.settings.muted = true
        settingsMenu.settings.sfxVolume = 0
    else
        settingsMenu.settings.muted = false
        settingsMenu.settings.sfxVolume = idx - 1
    end
    settingsMenu.applyVolume()
end

function settingsMenu.getHandIndex()
    return settingsMenu.settings.netPosition == "left" and 1 or 2
end

function settingsMenu.setHandFromIndex(idx)
    settingsMenu.settings.netPosition = idx == 1 and "left" or "right"
    gameState.settings.netPosition = settingsMenu.settings.netPosition
end

function settingsMenu.applySettings()
    settingsMenu.applyDisplay()
    settingsMenu.applyVolume()
    gameState.settings.netPosition = settingsMenu.settings.netPosition
end

function settingsMenu.applyDisplay()
    if settingsMenu.settings.fullscreen then
        love.window.setFullscreen(true, "desktop")
    else
        love.window.setFullscreen(false)
        local w = config.screen.width * settingsMenu.settings.windowScale
        local h = config.screen.height * settingsMenu.settings.windowScale
        love.window.setMode(w, h, { resizable = false })
    end

    local winW = love.graphics.getWidth()
    local winH = love.graphics.getHeight()
    local scale = math.min(winW / config.screen.width, winH / config.screen.height)
    local offsetX = math.floor((winW - config.screen.width * scale) / 2)
    local offsetY = math.floor((winH - config.screen.height * scale) / 2)

    gameState.display = {
        scale = scale,
        offsetX = offsetX,
        offsetY = offsetY,
    }

    input.screenScale = scale
    input.screenOffsetX = offsetX
    input.screenOffsetY = offsetY
end

function settingsMenu.applyVolume()
    local vol = settingsMenu.settings.muted and 0 or (settingsMenu.settings.sfxVolume / 10)
    love.audio.setVolume(vol)
end

function settingsMenu.saveSettings()
    local data = save.read() or {}
    data.settings = {
        windowScale = settingsMenu.settings.windowScale,
        fullscreen = settingsMenu.settings.fullscreen,
        sfxVolume = settingsMenu.settings.sfxVolume,
        muted = settingsMenu.settings.muted,
        netPosition = settingsMenu.settings.netPosition,
    }
    save.write(data)
end

function settingsMenu.getRows()
    return {
        { heading = "DISPLAY" },
        { label = "Scale", options = displayOptions, getIndex = settingsMenu.getDisplayIndex, setIndex = settingsMenu.setDisplayFromIndex },
        { heading = "AUDIO" },
        { label = "SFX", options = volumeOptions, getIndex = settingsMenu.getVolumeIndex, setIndex = settingsMenu.setVolumeFromIndex },
        { heading = "HAND" },
        { label = "Net Side", options = handOptions, getIndex = settingsMenu.getHandIndex, setIndex = settingsMenu.setHandFromIndex },
    }
end

function settingsMenu.cycleOption(row, direction)
    local idx = row.getIndex()
    idx = idx + direction
    if idx < 1 then idx = #row.options end
    if idx > #row.options then idx = 1 end
    row.setIndex(idx)
    assets.playSound(assets.audio.uiClick)
end

function settingsMenu.getRowY(popupY, index, rows)
    local y = popupY + settingsMenu.config.topPadding
    for i = 1, index - 1 do
        if rows[i].heading then
            y = y + settingsMenu.config.rowHeight + settingsMenu.config.sectionSpacing
        else
            y = y + settingsMenu.config.rowHeight
        end
    end
    return y
end

function settingsMenu.update(dt)
    if not settingsMenu.visible then return end

    settingsMenu.popup:update(dt)

    if not settingsMenu.popup:isActive() then
        settingsMenu.hoveredRow = nil
        settingsMenu.hoveredArrow = nil
        return
    end

    local mx, my = input.getMousePosition()
    local popupX, popupY = settingsMenu.popup:getPosition()
    local popupW = settingsMenu.popup.width

    local prevRow = settingsMenu.hoveredRow
    local prevArrow = settingsMenu.hoveredArrow
    settingsMenu.hoveredRow = nil
    settingsMenu.hoveredArrow = nil
    local rows = settingsMenu.getRows()
    for i, row in ipairs(rows) do
        if not row.heading then
            local ry = settingsMenu.getRowY(popupY, i, rows)
            if my >= ry and my <= ry + settingsMenu.config.rowHeight then
                settingsMenu.hoveredRow = i

                local valueX = popupX + popupW - settingsMenu.config.rowPadding - settingsMenu.config.valueWidth
                local arrowRightX = popupX + popupW - settingsMenu.config.rowPadding - 8
                local midX = (valueX + arrowRightX) / 2

                if mx >= valueX and mx < midX then
                    settingsMenu.hoveredArrow = "left"
                elseif mx >= midX and mx <= arrowRightX + 10 then
                    settingsMenu.hoveredArrow = "right"
                end
                break
            end
        end
    end
    if settingsMenu.hoveredRow and (settingsMenu.hoveredRow ~= prevRow or settingsMenu.hoveredArrow ~= prevArrow) then
        if settingsMenu.hoveredArrow then
            assets.playSound(assets.audio.uiHover)
        end
    end
end

function settingsMenu.mousepressed(x, y, button)
    if not settingsMenu.visible or not settingsMenu.popup:isActive() then
        return false
    end

    if settingsMenu.hoveredRow and settingsMenu.hoveredArrow then
        local rows = settingsMenu.getRows()
        local row = rows[settingsMenu.hoveredRow]
        if row and not row.heading then
            if settingsMenu.hoveredArrow == "left" then
                settingsMenu.cycleOption(row, -1)
            elseif settingsMenu.hoveredArrow == "right" then
                settingsMenu.cycleOption(row, 1)
            end
            return true
        end
    end

    return false
end

function settingsMenu.drawContent(popupX, popupY)
    local popupW = settingsMenu.popup.width
    local shadowColor = assets.shadowColor
    local rows = settingsMenu.getRows()

    for i, row in ipairs(rows) do
        local ry = settingsMenu.getRowY(popupY, i, rows)

        if row.heading then
            love.graphics.setFont(assets.fonts.fat)
            love.graphics.setColor(shadowColor)
            love.graphics.print(row.heading, popupX + settingsMenu.config.rowPadding + 1, ry + 1)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(row.heading, popupX + settingsMenu.config.rowPadding, ry)
        else
            local isHovered = settingsMenu.hoveredRow == i

            love.graphics.setFont(assets.fonts.m5x7)
            love.graphics.setColor(shadowColor)
            love.graphics.print(row.label, popupX + settingsMenu.config.rowPadding + 1, ry + 1)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(row.label, popupX + settingsMenu.config.rowPadding, ry)

            local valueX = popupX + popupW - settingsMenu.config.rowPadding - settingsMenu.config.valueWidth
            local currentIdx = row.getIndex()
            local currentValue = row.options[currentIdx]

            love.graphics.setFont(assets.fonts.fat)
            local leftArrowColor = (isHovered and settingsMenu.hoveredArrow == "left") and {1, 1, 1} or shadowColor
            love.graphics.setColor(leftArrowColor)
            love.graphics.print("<", valueX, ry - 1)

            local rightArrowX = popupX + popupW - settingsMenu.config.rowPadding - 8
            local rightArrowColor = (isHovered and settingsMenu.hoveredArrow == "right") and {1, 1, 1} or shadowColor
            love.graphics.setColor(rightArrowColor)
            love.graphics.print(">", rightArrowX, ry - 1)

            love.graphics.setFont(assets.fonts.m5x7)
            local textAreaX = valueX + 10
            local textAreaW = rightArrowX - textAreaX - 2
            love.graphics.setColor(shadowColor)
            love.graphics.printf(currentValue, textAreaX + 1, ry + 1, textAreaW, "center")
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(currentValue, textAreaX, ry, textAreaW, "center")
        end
    end

    -- Back hint at bottom
    love.graphics.setFont(assets.fonts.fat)
    local backY = popupY + settingsMenu.popup.height - 20
    love.graphics.setColor(shadowColor)
    love.graphics.printf("ESC to close", popupX + 1, backY + 1, popupW, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("ESC to close", popupX, backY, popupW, "center")
end

function settingsMenu.draw()
    if not settingsMenu.visible then return end
    settingsMenu.popup:draw()
end

return settingsMenu
