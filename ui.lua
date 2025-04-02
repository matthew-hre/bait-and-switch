local ui = {}

local config = require("config")
local assets = require("assets")
local gameState = require("gameState")

ui.config = {
    barMargin = 6,

    progressOffset = {
        x = 2,
        y = 1
    },

    animationSpeed = 5,
    resetAnimationSpeed = 8,
    shadowOffset = 2,
}

ui.progress = {
    current = 0,
    total = 5,
    progressWidth = 0,
    isResetting = false,
    resetStartWidth = 0
}

ui.waveInfo = {
    number = 1
}

function ui.load()
    ui.bar = assets.progressBar
    ui.shadowColor = assets.shadowColor
    
    ui.scale = config.screen.scale
    ui.screenWidth = config.screen.width
    ui.screenHeight = config.screen.height
    ui.shadowOffset = config.visual.shadowOffset
    
    ui.barX = (ui.screenWidth - ui.bar:getWidth()) / 2
    ui.barY = ui.screenHeight - ui.bar:getHeight() - ui.config.barMargin

    ui.fillColor = {0.96, 0.33, 0.36}
    
    ui.progress.progressWidth = 0
    
    ui.setProgress(gameState.stats.waveKills, gameState.killsPerWave)
    ui.setWaveNumber(gameState.stats.currentWave)
end

function ui.setProgress(current, total)
    if current < ui.progress.current or (ui.progress.current >= ui.progress.total and current < total) then
        ui.progress.isResetting = true
        ui.progress.resetStartWidth = ui.progress.progressWidth
    end
    
    ui.progress.current = current
    ui.progress.total = total
end

function ui.setWaveNumber(waveNumber)
    ui.waveInfo.number = waveNumber
end

function ui.update(dt)
    local barWidth = ui.bar:getWidth() - (2 * ui.config.progressOffset.x)

    if ui.progress.isResetting then
        ui.progress.progressWidth = lerp(
            ui.progress.progressWidth, 
            0,
            dt * ui.config.resetAnimationSpeed
        )
        
        if ui.progress.progressWidth < 1 then
            ui.progress.progressWidth = 0
            ui.progress.isResetting = false
        end
    else
        local targetWidth = barWidth * (ui.progress.current / ui.progress.total)
        
        ui.progress.progressWidth = math.max(0, math.min(barWidth, lerp(
            ui.progress.progressWidth, 
            targetWidth,
            dt * ui.config.animationSpeed
        )))
    end
end

function ui.draw()
    love.graphics.setColor(ui.shadowColor)
    love.graphics.draw(
        ui.bar, 
        ui.barX + ui.config.shadowOffset, 
        ui.barY + ui.config.shadowOffset
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        ui.bar, 
        ui.barX, 
        ui.barY
    )
    
    if ui.progress.progressWidth > 0 then
        love.graphics.setColor(ui.fillColor)
        
        local fillX = ui.barX + ui.config.progressOffset.x
        local fillY = ui.barY + ui.config.progressOffset.y
        
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
end

function lerp(a, b, t)
	return a + (b - a) * t
end

return ui
