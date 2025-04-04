local gameState = {
    killsPerWave = 10,
    stats = {
        killCount = 0,
        waveKills = 0,
        currentWave = 1
    },
    paused = false,
    pausedForUpgrade = false
}

return gameState