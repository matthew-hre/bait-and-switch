local scale = 4
local screenWidth, screenHeight = 256, 192
local windowWidth, windowHeight = screenWidth * scale, screenHeight * scale

local canvas
local shadowColor = {0, 105 / 255, 170 / 255, 1}

local player = require("player")
local assets = require("assets")
local net = require("net")

function love.load()
    love.window.setMode(windowWidth, windowHeight, { resizable = false })
    love.window.setTitle("Bait and Switch (LÖVE)")
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.mouse.setVisible(false)

    canvas = love.graphics.newCanvas(screenWidth, screenHeight)

    assets.load()
    player.load(assets)
    net.load(assets, player)
end

function love.update(dt)
    player.update(dt)
    net.update(dt)
end

function love.mousepressed(x, y, button)
    net.mousepressed(x, y, button)
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(assets.bg, 0, 0)

    player.draw()

    net.draw()

    drawCursor()

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, scale, scale)
end

function drawCursor()
    local mx, my = love.mouse.getPosition()
    mx = math.floor(mx / scale)
    my = math.floor(my / scale)

    local ox = assets.cursor:getWidth() / 2
    local oy = assets.cursor:getHeight() / 2
    local rot = love.timer.getTime() * 2

    love.graphics.setColor(assets.shadowColor)
    love.graphics.draw(assets.cursor, mx + 1, my + 1, rot, 1, 1, ox, oy)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(assets.cursor, mx, my, rot, 1, 1, ox, oy)
end
