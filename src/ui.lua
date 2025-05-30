local ui = {}

local config = require("src.config")
local assets = require("src.assets")
local gameState = require("src.gameState")
local player = require("src.player")
local utils = require("src.utils")

ui.config = {
    progress = {
        margin = 6,

        offset = {
            x = 2,
            y = 1
        },

        animationSpeed = 5,
        resetAnimationSpeed = 8,
        shadowOffset = 2,
        slideOutSpeed = 6,
    },

    hearts = {
        margin = 4,
        spacing = 2,
        scale = 1,
        shadowOffset = 1,
    },
}

ui.progress = {
    current = 0,
    total = 5,
    progressWidth = 0,
    isResetting = false,
    resetStartWidth = 0,
    slideOut = false, 
    yOffset = 0 
}

ui.hearts = {
    current = 3,
    max = 3
}

function ui.load()
    ui.bar = assets.ui.progressBar
    ui.shadowColor = assets.shadowColor
    ui.heartImage = assets.ui.heart
    
    ui.scale = config.screen.scale
    ui.screenWidth = config.screen.width
    ui.screenHeight = config.screen.height
    ui.shadowOffset = config.visual.shadowOffset
    
    ui.barX = (ui.screenWidth - ui.bar:getWidth()) / 2
    ui.barY = ui.screenHeight - ui.bar:getHeight() - ui.config.progress.margin

    ui.fillColor = {0.96, 0.33, 0.36}
    
    ui.progress.progressWidth = 0
    
    ui.setProgress(gameState.stats.waveKills, gameState.killsPerWave)

    ui.setHealth(3)
    
    ui.hearts.max = player.config.maxHealth
    ui.hearts.current = player.health

    ui.progress.slideOut = false
    ui.progress.yOffset = 0
end

function ui.setProgress(current, total)
    if current < ui.progress.current or (ui.progress.current >= ui.progress.total and current < total) then
        ui.progress.isResetting = true
        ui.progress.resetStartWidth = ui.progress.progressWidth
    end
    
    ui.progress.current = current
    ui.progress.total = total
end

function ui.setHealth(health)
    ui.hearts.current = math.max(0, math.min(ui.hearts.max, health))
end

function ui.startSlideOut()
    ui.progress.slideOut = true
end

function ui.update(dt)
    local barWidth = ui.bar:getWidth() - (2 * ui.config.progress.offset.x)

    if ui.progress.slideOut then
        ui.progress.yOffset = ui.progress.yOffset + 
            (ui.bar:getHeight() + ui.config.progress.margin * 2) * dt * ui.config.progress.slideOutSpeed
        
        return
    end

    if ui.progress.isResetting then
        ui.progress.progressWidth = utils.lerp(
            ui.progress.progressWidth, 
            0,
            dt * ui.config.progress.resetAnimationSpeed
        )
        
        if ui.progress.progressWidth < 1 then
            ui.progress.progressWidth = 0
            ui.progress.isResetting = false
        end
    else
        local targetWidth = barWidth * (ui.progress.current / ui.progress.total)
        
        ui.progress.progressWidth = math.max(0, math.min(barWidth, utils.lerp(
            ui.progress.progressWidth, 
            targetWidth,
            dt * ui.config.progress.animationSpeed
        )))
    end
end

function ui.draw()
    utils.drawWithShadow(
        ui.bar, 
        ui.barX, 
        ui.barY + ui.progress.yOffset,
        0,
        1,
        1,
        0,
        0,
        ui.config.progress.shadowOffset,
        ui.shadowColor
    )
    
    if ui.progress.progressWidth > 0 then
        love.graphics.setColor(ui.fillColor)
        
        local fillX = ui.barX + ui.config.progress.offset.x
        local fillY = ui.barY + ui.config.progress.offset.y + ui.progress.yOffset
        
        love.graphics.rectangle(
            "fill",
            fillX,
            fillY + 1,
            ui.progress.progressWidth,
            3
        )
        
        love.graphics.rectangle(
            "fill",
            fillX + 1,
            fillY,
            ui.progress.progressWidth - 2,
            5
        )
    end
    
    local heartScale = ui.config.hearts.scale
    local heartX = ui.config.hearts.margin
    local heartY = ui.config.hearts.margin
    local heartWidth = ui.heartImage:getWidth() * heartScale
    local heartShadowOffset = ui.config.hearts.shadowOffset
    
    for i = 1, ui.hearts.current do
        utils.drawWithShadow(
            ui.heartImage,
            heartX,
            heartY,
            0,
            heartScale,
            heartScale,
            0,
            0,
            heartShadowOffset,
            ui.shadowColor
        )
        
        heartX = heartX + heartWidth + ui.config.hearts.spacing
    end
end

return ui
