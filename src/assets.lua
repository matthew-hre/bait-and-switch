local assets = {}

local config = require("src.config")

function assets.load()
    assets.bg = love.graphics.newImage("assets/bg.png")
    assets.cursor = love.graphics.newImage("assets/cursor.png")

    assets.playerSprite = love.graphics.newImage("assets/player.png")

    assets.netSprite = love.graphics.newImage("assets/net.png")
    assets.netLoadedSprite = love.graphics.newImage("assets/netLoaded.png")

    assets.enemySprite = love.graphics.newImage("assets/enemy.png")
    
    -- create this here as not to bog down the particle system
    assets.whiteSquare = love.graphics.newCanvas(4, 4)
    love.graphics.setCanvas(assets.whiteSquare)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 4, 4)
    love.graphics.setCanvas()
    
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
    
    assets.primaryColor = {1, 0.6, 0.2, 1} -- Orange/fire color
    assets.shadowColor = config.visual.shadowColor
end

return assets
