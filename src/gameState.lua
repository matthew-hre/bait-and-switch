local gameState = {
    current = "MAIN_MENU",

    killsPerWave = 13,
    waveScaleFactor = 1.4,
    stats = {
        killCount = 0,
        waveKills = 0,
        currentWave = 1
    },
    tutorialMode = true,
    
    settings = {
        netPosition = "left",
    },
    
    deathScreen = {
        deathAnimationDelay = 0,
        deathAnimationTimer = 0,
        timer = 0,
        textRevealTimer = 0,
        displayedLines = 0,
        lineDelay = 0.6,
        restartDelay = 4.0,
        bestWave = 1
    }
}

function gameState.isPaused()
    local s = gameState.current
    return s == "PAUSED_MENU" or s == "PAUSED_SETTINGS" or s == "PAUSED_UPGRADE"
end

return gameState