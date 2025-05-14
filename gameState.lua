local gameState = {
    killsPerWave = 13,
    waveScaleFactor = 1.4,
    stats = {
        killCount = 0,
        waveKills = 0,
        currentWave = 1
    },
    paused = false,
    pausedForUpgrade = false,
    pausedForPause = false,
    tutorialMode = true,
    
    settings = {
        netPosition = "left", -- Moved from config.lua for runtime mutability
    },
    
    deathScreen = {
        active = false,
        showDeathScreen = false,
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

return gameState