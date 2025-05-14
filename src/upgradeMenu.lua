local upgradeMenu = {}

local config = require("src.config")
local assets = require("src.assets")
local gameState = require("src.gameState")
local input = require("src.input")

local Popup = require("src.ui.popup")
local UpgradeList = require("src.ui.upgradeList")

function upgradeMenu.load()
    local player = require("src.player")
    local projectile = require("src.projectile")
    
    upgradeMenu.availableUpgrades = {
        -- { name = "kablooey", description = "every few fired bugs explode", image = assets.ui.upgrades.bomb },
        { 
            name = "bouncey bugs", 
            description = "bugs bounce more", 
            image = assets.ui.upgrades.bounce,
            effect = function()
                projectile.config.maxBounces = projectile.config.maxBounces + 1
            end
        },
        -- { name = "bzzt!", description = "fired bugs have a little juice", image = assets.ui.upgrades.electric },
        { 
            name = "i love u", 
            description = "bug kissed u. heal +2", 
            image = assets.ui.upgrades.heart,
            effect = function()
                local ui = require("src.ui")
                player.health = math.min(player.config.maxHealth, player.health + 2)
                ui.setHealth(player.health)
            end
        },
        { 
            name = "bigger bugs", 
            description = "fired bugs are 10% bigger", 
            image = assets.ui.upgrades.shotsizeup,
            effect = function()
                projectile.size = (projectile.size or 1) * 1.1
            end
        },
        { 
            name = "size down", 
            description = "10% smaller, 10% faster", 
            image = assets.ui.upgrades.sizedown,
            effect = function()
                player.scale = (player.scale or 1) * 0.9
                player.speed = player.speed * 1.1
            end
        },
        { 
            name = "shootin' snails", 
            description = "fired bugs are 20% slower", 
            image = assets.ui.upgrades.slow,
            effect = function()
                projectile.config.speed = projectile.config.speed * 0.8
            end
        },
        -- { name = "split shot", description = "two shots, 60%", image = assets.ui.upgrades.splitshot },
    }

    upgradeMenu.list = UpgradeList.new({
        upgrades = upgradeMenu.availableUpgrades,
        shadowColor = assets.shadowColor,
        onSelect = function(upgrade)
            if upgrade.effect then
                upgrade.effect()
            end
            upgradeMenu.hide()
        end
    })
    
    upgradeMenu.popup = Popup.new({
        sprite = assets.ui.popup,
        shadowColor = assets.shadowColor,
        onShow = function()
            upgradeMenu.list:getRandomUpgrades()
        end,
        onHideComplete = function()
            gameState.paused = false
            gameState.pausedForUpgrade = false
        end,
        
        drawContent = function(popup, x, y)
            upgradeMenu.list:draw(x, y)
        end
    })
end

function upgradeMenu.show()
    if upgradeMenu.popup.visible then return end
    
    gameState.killsPerWave = math.ceil(gameState.killsPerWave * gameState.waveScaleFactor)
    
    gameState.paused = true
    gameState.pausedForUpgrade = true
    
    upgradeMenu.popup:show()
end

function upgradeMenu.hide()
    upgradeMenu.popup:hide()
end

function upgradeMenu.update(dt)
    if not upgradeMenu.popup.visible then return end
    
    upgradeMenu.popup:update(dt)
    
    if upgradeMenu.popup:isActive() then
        local popupX, popupY = upgradeMenu.popup:getPosition()
        upgradeMenu.list:update(dt, popupX, popupY, upgradeMenu.popup.width)
    end
end

function upgradeMenu.draw()
    upgradeMenu.popup:draw()
end

function upgradeMenu.mousepressed(x, y, button)
    if not upgradeMenu.popup.visible or 
       not upgradeMenu.popup:isActive() then
        return false
    end
    
    local popupX, popupY = upgradeMenu.popup:getPosition()
    return upgradeMenu.list:mousepressed(x, y, button)
end

return upgradeMenu
