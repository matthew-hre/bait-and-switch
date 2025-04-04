local config = require("config")
local canvas

local player = require("player")
local assets = require("assets")
local net = require("net")
local enemy = require("enemy")
local projectile = require("projectile")
local particle = require("particle")

local gameState = require("gameState")
local upgradeMenu = require("upgradeMenu")

local ui = require("ui")

function love.load()
    love.window.setMode(config.window.width, config.window.height, { resizable = false })
    love.window.setTitle(config.game.title)
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.mouse.setVisible(false)

    canvas = love.graphics.newCanvas(config.screen.width, config.screen.height)

    assets.load()
    player.load()
    enemy.load()
    net.load()
    projectile.load()
    particle.load()
    ui.load()
    upgradeMenu.load()
end

function love.update(dt)
    if gameState.paused then
        upgradeMenu.update(dt)
        ui.update(dt)
        return
    end
    
    player.update(dt)
    net.update(dt)
    enemy.update(dt)
    projectile.update(dt)
    particle.update(dt)
    
    ui.setProgress(gameState.stats.waveKills, gameState.killsPerWave)
    
    ui.update(dt)

    if player.health <= 0 then
        love.event.quit("restart")
    end
end

function love.mousepressed(x, y, button)
    if gameState.pausedForUpgrade then
        if upgradeMenu.mousepressed(x, y, button) then
            return
        end
    end
    
    net.mousepressed(x, y, button)
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(assets.bg, 0, 0)

    player.draw()
    enemy.draw()
    net.draw()
    projectile.draw()
    particle.draw()

    ui.draw()
    
    upgradeMenu.draw()

    drawCursor()

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, config.screen.scale, config.screen.scale)
end

function drawCursor()
    local mx, my = love.mouse.getPosition()
    mx = math.floor(mx / config.screen.scale)
    my = math.floor(my / config.screen.scale)

    local ox = assets.cursor:getWidth() / 2
    local oy = assets.cursor:getHeight() / 2
    local rot = love.timer.getTime() * 2

    love.graphics.setColor(config.visual.shadowColor)
    love.graphics.draw(assets.cursor, mx + 1, my + 1, rot, 1, 1, ox, oy)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(assets.cursor, mx, my, rot, 1, 1, ox, oy)
end
