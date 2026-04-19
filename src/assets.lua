local assets = {}

local config = require("src.config")

function assets.load()
    assets.bg = love.graphics.newImage("assets/bg.png")
    assets.cursor = love.graphics.newImage("assets/cursor.png")

    assets.playerSprite = love.graphics.newImage("assets/player.png")

    assets.netSprite = love.graphics.newImage("assets/net.png")
    assets.netLoadedSprite = love.graphics.newImage("assets/netLoaded.png")

    assets.enemySprite = love.graphics.newImage("assets/enemy.png")
    
    local squareData = love.image.newImageData(4, 4)
    squareData:mapPixel(function() return 1, 1, 1, 1 end)
    assets.whiteSquare = love.graphics.newImage(squareData)
    
    assets.ui = {}
    assets.ui.progress = love.graphics.newImage("assets/ui/progress.png")
    assets.ui.progressBar = love.graphics.newImage("assets/ui/progressBar.png")
    assets.ui.heart = love.graphics.newImage("assets/ui/heart.png")
    assets.ui.popup = love.graphics.newImage("assets/ui/popup.png")

    assets.ui.upgrades = {}
    assets.ui.upgrades.bomb = love.graphics.newImage("assets/ui/upgrades/bomb.png")
    assets.ui.upgrades.bounce = love.graphics.newImage("assets/ui/upgrades/bounce.png")
    assets.ui.upgrades.electric = love.graphics.newImage("assets/ui/upgrades/electric.png")
    assets.ui.upgrades.heart = love.graphics.newImage("assets/ui/upgrades/heart.png")
    assets.ui.upgrades.shotsizeup = love.graphics.newImage("assets/ui/upgrades/shotsizeup.png")
    assets.ui.upgrades.sizedown = love.graphics.newImage("assets/ui/upgrades/sizedown.png")
    assets.ui.upgrades.slow = love.graphics.newImage("assets/ui/upgrades/slow.png")
    assets.ui.upgrades.splitshot = love.graphics.newImage("assets/ui/upgrades/splitshot.png")

    assets.ui.tutorial = {}
    assets.ui.tutorial.click = love.graphics.newImage("assets/ui/tutorial/click.png")
    assets.ui.tutorial.walk = love.graphics.newImage("assets/ui/tutorial/walk.png")

    assets.fonts = {}
    assets.fonts.fat = love.graphics.newFont("assets/fonts/fat.ttf", 16)
    assets.fonts.fat:setFilter("nearest", "nearest")

    assets.fonts.m5x7 = love.graphics.newFont("assets/fonts/m5x7.ttf", 16)
    assets.fonts.m5x7:setFilter("nearest", "nearest")
    
    assets.audio = {}
    assets.audio.netSwing = love.audio.newSource("assets/audio/netSwing.wav", "static")
    assets.audio.bugCatch = love.audio.newSource("assets/audio/bugCatch.wav", "static")
    assets.audio.projectileFire = love.audio.newSource("assets/audio/projectileFire.wav", "static")
    assets.audio.enemyDeath = love.audio.newSource("assets/audio/enemyDeath.wav", "static")
    assets.audio.playerHit = love.audio.newSource("assets/audio/playerHit.wav", "static")
    assets.audio.bounce = love.audio.newSource("assets/audio/bounce.wav", "static")
    assets.audio.uiHover = love.audio.newSource("assets/audio/uiHover.wav", "static")
    assets.audio.uiClick = love.audio.newSource("assets/audio/uiClick.wav", "static")
    assets.audio.upgradeSelect = love.audio.newSource("assets/audio/upgradeSelect.wav", "static")
    assets.audio.waveComplete = love.audio.newSource("assets/audio/waveComplete.wav", "static")
    assets.audio.gameOver = love.audio.newSource("assets/audio/gameOver.wav", "static")

    assets.primaryColor = {1, 0.6, 0.2, 1} -- Orange/fire color
    assets.shadowColor = config.visual.shadowColor
end

function assets.playSound(sound, pitchVariance)
    local s = sound:clone()
    if pitchVariance then
        s:setPitch(1 + (math.random() * 2 - 1) * pitchVariance)
    end
    s:play()
end

return assets
