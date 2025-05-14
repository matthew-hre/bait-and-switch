local config = require("config")
local canvas

local player = require("player")
local assets = require("assets")
local net = require("net")
local enemy = require("enemy")
local projectile = require("projectile")
local particle = require("particle")
local tutorial = require("tutorial")

local gameState = require("gameState")
local upgradeMenu = require("upgradeMenu")
local deathScreen = require("deathScreen")
local pauseMenu = require("pauseMenu")

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
    pauseMenu.load()
    tutorial.load()
end

function love.update(dt)
    particle.update(dt)
    
    ui.update(dt)
    
    projectile.update(dt)
    
    if gameState.deathScreen.showDeathScreen then
        deathScreen.update(dt)
        return
    end
    
    if gameState.paused then
        if gameState.pausedForUpgrade then
            upgradeMenu.update(dt)
        elseif gameState.pausedForPause then
            pauseMenu.update(dt)
        end
        return
    end
    
    player.update(dt)
    net.update(dt)
    
    -- Update tutorial logic before enemy update
    tutorial.update(dt)
    
    -- Only update enemy system if tutorial mode is complete
    if not gameState.tutorialMode then
        enemy.update(dt)
    else
        -- Just update existing enemies (e.g. tutorial bug's rotation) but don't spawn new ones
        for i = #enemy.active, 1, -1 do
            local e = enemy.active[i]
            
            if e.dead then
                table.remove(enemy.active, i)
            elseif not e.caught and not e.isTutorialBug then
                -- Process regular bug movement
                -- No need to update the tutorial bug as it's handled in tutorial.update
            end
        end
    end
    
    ui.setProgress(gameState.stats.waveKills, gameState.killsPerWave)
end

function love.mousepressed(x, y, button)
    if gameState.deathScreen.active or gameState.deathScreen.showDeathScreen then
        return
    end

    if gameState.pausedForUpgrade then
        if upgradeMenu.mousepressed(x, y, button) then
            return
        end
    elseif gameState.pausedForPause then
        if pauseMenu.mousepressed(x, y, button) then
            return
        end
    end
    
    net.mousepressed(x, y, button)
end

function love.keypressed(key)
    if key == "escape" then
        if not gameState.deathScreen.active and 
           not gameState.deathScreen.showDeathScreen and
           not gameState.pausedForUpgrade then
            pauseMenu.toggle()
        end
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(assets.bg, 0, 0)

    if not player.dead then
        player.draw()
    end
    
    enemy.draw()
    
    net.draw()
    
    projectile.draw()

    particle.draw()
    
    -- Draw tutorial elements
    tutorial.draw()

    ui.draw()
    
    if not gameState.deathScreen.active and not gameState.deathScreen.showDeathScreen then
        upgradeMenu.draw()
        pauseMenu.draw()
    end

    if gameState.deathScreen.active then
        deathScreen.draw()
    end

    if not gameState.deathScreen.active and not gameState.deathScreen.showDeathScreen then
        drawCursor()
    end

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
