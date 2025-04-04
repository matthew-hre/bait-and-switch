local assets = {}

local config = require("config")

function assets.load()
    assets.bg = love.graphics.newImage("assets/bg.png")
    assets.cursor = love.graphics.newImage("assets/cursor.png")

    assets.playerSprite = love.graphics.newImage("assets/player.png")

    assets.netSprite = love.graphics.newImage("assets/net.png")
    assets.netLoadedSprite = love.graphics.newImage("assets/netLoaded.png")

    assets.enemySprite = love.graphics.newImage("assets/enemy.png")
    
    assets.progress = love.graphics.newImage("assets/progress.png")
    assets.progressBar = love.graphics.newImage("assets/progressBar.png")

    assets.heart = love.graphics.newImage("assets/heart.png")

    assets.popup = love.graphics.newImage("assets/popup.png")
    
    assets.shadowColor = config.visual.shadowColor
end

return assets
