local assets = {}

local config = require("config")

function assets.load()
    assets.bg = love.graphics.newImage("assets/bg.png")
    assets.cursor = love.graphics.newImage("assets/cursor.png")

    assets.playerSprite = love.graphics.newImage("assets/player.png")

    assets.netSprite = love.graphics.newImage("assets/net.png")
    assets.netLoadedSprite = love.graphics.newImage("assets/netLoaded.png")

    assets.enemySprite = love.graphics.newImage("assets/enemy.png")
    
    assets.ui.progress = love.graphics.newImage("assets/ui/progress.png")
    assets.ui.progressBar = love.graphics.newImage("assets/ui/progressBar.png")
    assets.ui.heart = love.graphics.newImage("assets/ui/heart.png")
    assets.ui.popup = love.graphics.newImage("assets/ui/popup.png")

    assets.ui.upgrades.bomb = love.graphics.newImage("assets/ui/upgrades/bomb.png")
    assets.ui.upgrades.bounce = love.graphics.newImage("assets/ui/upgrades/bounce.png")
    assets.ui.upgrades.electric = love.graphics.newImage("assets/ui/upgrades/electric.png")
    assets.ui.upgrades.heart = love.graphics.newImage("assets/ui/upgrades/heart.png")
    assets.ui.upgrades.shotsizeup = love.graphics.newImage("assets/ui/upgrades/shotsizeup.png")
    assets.ui.upgrades.sizedown = love.graphics.newImage("assets/ui/upgrades/sizedown.png")
    assets.ui.upgrades.slow = love.graphics.newImage("assets/ui/upgrades/slow.png")
    assets.ui.upgrades.splitshot = love.graphics.newImage("assets/ui/upgrades/splitshot.png")

    assets.ui.tutorial.click = love.graphics.newImage("assets/ui/tutorial/click.png")
    assets.ui.tutorial.walk = love.graphics.newImage("assets/ui/tutorial/walk.png")
    
    assets.shadowColor = config.visual.shadowColor
end

return assets
