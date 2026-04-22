local config = require("src.config")
local canvas

local player = require("src.player")
local assets = require("src.assets")
local net = require("src.net")
local enemy = require("src.enemy")
local projectile = require("src.projectile")
local particle = require("src.particle")
local speedyBug = require("src.speedyBug")
local tutorial = require("src.tutorial")
local utils = require("src.utils")

local gameState = require("src.gameState")
local mainMenu = require("src.mainMenu")
local upgradeMenu = require("src.upgradeMenu")
local deathScreen = require("src.deathScreen")
local pauseMenu = require("src.pauseMenu")
local settingsMenu = require("src.settingsMenu")

local ui = require("src.ui")
local input = require("src.input")
local save = require("src.save")

function love.load()
    love.window.setMode(config.window.width, config.window.height, { resizable = false })
    love.window.setTitle(config.game.title)
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.mouse.setVisible(false)

    canvas = love.graphics.newCanvas(config.screen.width, config.screen.height)

    assets.load()
    input.load()
    player.load()
    enemy.load()
    net.load()
    projectile.load()
    speedyBug.load()
    particle.load()
    ui.load()
    upgradeMenu.load()
    pauseMenu.load()
    settingsMenu.load()
    tutorial.load()
    mainMenu.load()

    local data = save.read()
    if data then
        gameState.deathScreen.bestWave = data.bestWave or 1
    end
end

local stateUpdate = {}

function stateUpdate.MAIN_MENU(dt)
    mainMenu.update(dt)
end

function stateUpdate.MAIN_MENU_SETTINGS(dt)
    settingsMenu.update(dt)
    if input.isActionPressed("pause") then
        settingsMenu.hide()
    end
end

function stateUpdate.MENU_TO_PLAY(dt)
    mainMenu.update(dt)
end

function stateUpdate.PLAYING(dt)
    if mainMenu.fadingOut then
        mainMenu.fadeOutAlpha = mainMenu.fadeOutAlpha - dt * mainMenu.config.fadeOutSpeed
        if mainMenu.fadeOutAlpha <= 0 then
            mainMenu.fadeOutAlpha = 0
            mainMenu.fadingOut = false
        end
    end

    particle.update(dt)
    ui.update(dt)
    projectile.update(dt)
    player.update(dt)
    net.update(dt)
    tutorial.update(dt)

    speedyBug.update(dt)
    
    if not gameState.tutorialMode then
        enemy.update(dt)
    else
        local n = #enemy.active
        local i = 1
        while i <= n do
            local e = enemy.active[i]
            if e.dead then
                enemy.active[i] = enemy.active[n]
                enemy.active[n] = nil
                n = n - 1
            else
                i = i + 1
            end
        end
    end

    ui.setProgress(gameState.stats.waveKills, gameState.killsPerWave)

    if input.isActionPressed("pause") then
        pauseMenu.toggle()
    end
end

function stateUpdate.PAUSED_MENU(dt)
    pauseMenu.update(dt)
    if input.isActionPressed("pause") then
        pauseMenu.toggle()
    end
end

function stateUpdate.PAUSED_SETTINGS(dt)
    settingsMenu.update(dt)
    if input.isActionPressed("pause") then
        settingsMenu.hide()
    end
end

function stateUpdate.PAUSED_UPGRADE(dt)
    upgradeMenu.update(dt)
end

function stateUpdate.DEATH_ANIMATING(dt)
    particle.update(dt)
    projectile.update(dt)
    speedyBug.update(dt)
    deathScreen.update(dt)
end

function stateUpdate.DEATH_SCREEN(dt)
    deathScreen.update(dt)
end

function love.update(dt)
    input.update()
    stateUpdate[gameState.current](dt)
    input.clear()
end

local stateMousepressed = {}

function stateMousepressed.MAIN_MENU(x, y, button)
    mainMenu.mousepressed(x, y, button)
end

function stateMousepressed.MAIN_MENU_SETTINGS(x, y, button)
    settingsMenu.mousepressed(x, y, button)
end

function stateMousepressed.MENU_TO_PLAY() end

function stateMousepressed.PLAYING(x, y, button)
    net.mousepressed(x, y, button)
end

function stateMousepressed.PAUSED_MENU(x, y, button)
    pauseMenu.mousepressed(x, y, button)
end

function stateMousepressed.PAUSED_SETTINGS(x, y, button)
    settingsMenu.mousepressed(x, y, button)
end

function stateMousepressed.PAUSED_UPGRADE(x, y, button)
    upgradeMenu.mousepressed(x, y, button)
end

function stateMousepressed.DEATH_ANIMATING() end
function stateMousepressed.DEATH_SCREEN() end

function love.mousepressed(x, y, button)
    input.mousepressed(x, y, button)
    stateMousepressed[gameState.current](x, y, button)
end

function love.mousereleased(x, y, button)
    input.mousereleased(x, y, button)
end

function love.keypressed(key)
    input.keypressed(key)
end

function love.keyreleased(key)
    input.keyreleased(key)
end

local function drawGameWorld()
    if not player.dead then
        player.draw()
    end
    enemy.draw()
    speedyBug.draw()
    net.draw()
    projectile.draw()
    particle.draw()
    tutorial.draw()
    ui.draw()
end

local function drawCanvasToScreen()
    love.graphics.setCanvas()
    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1)
    local display = gameState.display
    if display then
        love.graphics.draw(canvas, display.offsetX, display.offsetY, 0, display.scale, display.scale)
    else
        local scaleX = love.graphics.getWidth() / config.screen.width
        local scaleY = love.graphics.getHeight() / config.screen.height
        love.graphics.draw(canvas, 0, 0, 0, scaleX, scaleY)
    end
end

local stateDraw = {}

function stateDraw.MAIN_MENU()
    mainMenu.draw()
    drawCursor()
end

function stateDraw.MAIN_MENU_SETTINGS()
    mainMenu.draw()
    settingsMenu.draw()
    drawCursor()
end

function stateDraw.MENU_TO_PLAY()
    mainMenu.draw()
    drawCursor()
end

function stateDraw.PLAYING()
    drawGameWorld()

    if mainMenu.fadingOut then
        love.graphics.setColor(1, 1, 1, mainMenu.fadeOutAlpha)
        love.graphics.draw(assets.bg, 0, 0)
    end

    drawCursor()
end

function stateDraw.PAUSED_MENU()
    drawGameWorld()
    pauseMenu.draw()
    drawCursor()
end

function stateDraw.PAUSED_SETTINGS()
    drawGameWorld()
    settingsMenu.draw()
    drawCursor()
end

function stateDraw.PAUSED_UPGRADE()
    drawGameWorld()
    upgradeMenu.draw()
    drawCursor()
end

function stateDraw.DEATH_ANIMATING()
    drawGameWorld()
end

function stateDraw.DEATH_SCREEN()
    drawGameWorld()
    deathScreen.draw()
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(assets.bg, 0, 0)

    stateDraw[gameState.current]()

    drawCanvasToScreen()
end

function drawCursor()
    local mx, my = input.getMousePosition()
    local ox = assets.cursor:getWidth() / 2
    local oy = assets.cursor:getHeight() / 2
    local rot = love.timer.getTime() * 2

    utils.drawWithShadow(assets.cursor, mx, my, rot, 1, 1, ox, oy, 1, config.visual.shadowColor)
end
