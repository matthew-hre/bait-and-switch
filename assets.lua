local assets = {}

function assets.load()
    assets.bg = love.graphics.newImage("assets/bg.png")
    assets.playerSprite = love.graphics.newImage("assets/player.png")
    assets.netSprite = love.graphics.newImage("assets/net.png")
    assets.cursor = love.graphics.newImage("assets/cursor.png")

    assets.shadowColor = { 0, 105 / 255, 170 / 255, 1 }
end

return assets
