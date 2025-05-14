local deathScreen = {}

local config = require("src.config")
local assets = require("src.assets")
local gameState = require("src.gameState")
local utils = require("src.utils")

deathScreen.config = {
    textRevealDelay = 1,
    restartDelay = 8.0,
    deathAnimationDelay = 1,
    
    textStyle = {
        lineSpacing = 14,
        titleShadowOffset = 2,
        textShadowOffset = 1
    }
}

function deathScreen.init()
    if gameState.stats.currentWave > gameState.deathScreen.bestWave then
        gameState.deathScreen.bestWave = gameState.stats.currentWave
    end

    gameState.deathScreen.timer = 0
    gameState.deathScreen.textRevealTimer = 0
    gameState.deathScreen.displayedLines = 0

    local projectile = require("src.projectile")
    projectile.clearAllBounces()

    deathScreen.lines = {
        "GAME OVER",
        "you made it to wave " .. gameState.stats.currentWave,
        "your best was wave " .. gameState.deathScreen.bestWave
    }
end

function deathScreen.resetGame()
    local bestWave = gameState.deathScreen.bestWave
    
    gameState.stats.killCount = 0
    gameState.stats.waveKills = 0
    gameState.stats.currentWave = 1
    gameState.paused = false
    gameState.pausedForUpgrade = false
    gameState.tutorialMode = true
    
    gameState.killsPerWave = 13
    
    gameState.deathScreen.active = false
    gameState.deathScreen.showDeathScreen = false
    gameState.deathScreen.deathAnimationTimer = 0
    
    gameState.deathScreen.bestWave = bestWave
    
    local player = require("src.player")
    local enemy = require("src.enemy")
    local projectile = require("src.projectile")
    local net = require("src.net")
    local ui = require("src.ui")
    local tutorial = require("src.tutorial")
    
    enemy.active = {}
    projectile.active = {}
    
    player.load()
    tutorial.load()
    
    net.visible = true
    net.loaded = false
    net.swinging = false
    net.x = config.screen.width / 2
    net.y = config.screen.height / 2
    
    ui.setHealth(player.health)
    ui.setProgress(0, gameState.killsPerWave)
end

function deathScreen.update(dt)
    if gameState.deathScreen.showDeathScreen and not gameState.deathScreen.active then
        gameState.deathScreen.deathAnimationTimer = gameState.deathScreen.deathAnimationTimer + dt
        
        if gameState.deathScreen.deathAnimationTimer >= deathScreen.config.deathAnimationDelay then
            gameState.deathScreen.active = true
            deathScreen.init()
        end
        
        return
    end
    
    gameState.deathScreen.timer = gameState.deathScreen.timer + dt
    
    gameState.deathScreen.textRevealTimer = gameState.deathScreen.textRevealTimer + dt
    
    if gameState.deathScreen.displayedLines < #deathScreen.lines and 
       gameState.deathScreen.textRevealTimer >= deathScreen.config.textRevealDelay then
        gameState.deathScreen.displayedLines = gameState.deathScreen.displayedLines + 1
        gameState.deathScreen.textRevealTimer = 0
    end
    
    if gameState.deathScreen.timer >= deathScreen.config.restartDelay then
        deathScreen.resetGame()
    end
end

function deathScreen.draw()
    local centerX = config.screen.width / 2
    local startY = config.screen.height / 2 - (#deathScreen.lines * 16) / 2
    
    for i = 1, gameState.deathScreen.displayedLines do
        local text = deathScreen.lines[i]
        
        if i == 1 then
            love.graphics.setFont(assets.fonts.fat)
        else
            love.graphics.setFont(assets.fonts.m5x7)
        end
        
        local textWidth = love.graphics.getFont():getWidth(text)
        local shadowOffset = (i == 1) and deathScreen.config.textStyle.titleShadowOffset or deathScreen.config.textStyle.textShadowOffset
        local textX = math.floor(centerX - textWidth / 2)
        local textY = math.floor(startY + (i-1) * deathScreen.config.textStyle.lineSpacing)
        
        love.graphics.setColor(assets.shadowColor)
        love.graphics.print(
            text, 
            textX + shadowOffset, 
            textY + shadowOffset
        )
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(
            text, 
            textX, 
            textY
        )
    end
end

return deathScreen
