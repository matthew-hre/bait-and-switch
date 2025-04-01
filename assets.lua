local assets = {}

function assets.load(config)
    assets.bg = love.graphics.newImage("assets/bg.png")
    assets.playerSprite = love.graphics.newImage("assets/player.png")
    assets.netSprite = love.graphics.newImage("assets/net.png")
    assets.netLoadedSprite = love.graphics.newImage("assets/netLoaded.png")
    assets.cursor = love.graphics.newImage("assets/cursor.png")
    assets.enemySprite = love.graphics.newImage("assets/enemy.png")

    assets.shadowColor = config.visual.shadowColor
end

return assets
