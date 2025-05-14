local upgradeMenu = {}

local config = require("config")
local assets = require("assets")
local gameState = require("gameState")
local utils = require("utils")
local input = require("src.input")

upgradeMenu.config = {
    slideSpeed = 5,
    startY = -200,
    exitSpeed = 7,
    
    iconWiggle = {
        maxRotation = math.rad(12),
        speed = 5,
    },
    textShift = {
        x = -2,
        y = -2,
        titleShadow = 2,
        descShadow = 1,
        animationSpeed = 20,        
    },
    upgradeHeight = 36,

    popupShadow = { x = 2, y = 2 },
    iconShadow = { x = 2, y = 2 },
    iconXOffset = 12,
    textXOffset = 42,
    upgradesTopPadding = 16,
    descriptionYOffset = 12,
}

function upgradeMenu.load()
    local player = require("player")
    local projectile = require("projectile")
    
    upgradeMenu.popup = assets.ui.popup
    upgradeMenu.shadowColor = assets.shadowColor
    upgradeMenu.visible = false
    upgradeMenu.isAnimating = false
    upgradeMenu.isExiting = false
    upgradeMenu.y = upgradeMenu.config.startY
    upgradeMenu.targetY = 0 -- will be calculated when shown
    upgradeMenu.width = assets.ui.popup:getWidth()
    upgradeMenu.height = assets.ui.popup:getHeight()
    
    upgradeMenu.hoverIndex = nil
    upgradeMenu.wiggleTime = 0
    upgradeMenu.textAnimationStates = {}

    upgradeMenu.upgrades = {
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
                local ui = require("ui")
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
end

local function getRandomUpgrades()
    local shuffled = {}
    for _, upgrade in ipairs(upgradeMenu.upgrades) do
        table.insert(shuffled, upgrade)
    end
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    
    upgradeMenu.textAnimationStates = {}
    for i = 1, 3 do
        upgradeMenu.textAnimationStates[i] = {
            actualX = 0,
            actualY = 0,
            targetX = 0,
            targetY = 0
        }
    end
    
    return { shuffled[1], shuffled[2], shuffled[3] }
end

function upgradeMenu.show()
    if upgradeMenu.visible then return end
    
    gameState.killsPerWave = math.ceil(gameState.killsPerWave * gameState.waveScaleFactor)
    
    upgradeMenu.visible = true
    upgradeMenu.isAnimating = true
    upgradeMenu.isExiting = false
    upgradeMenu.y = upgradeMenu.config.startY
    
    upgradeMenu.targetY = (config.screen.height - upgradeMenu.height) / 2
    
    gameState.paused = true
    gameState.pausedForUpgrade = true

    upgradeMenu.randomUpgrades = getRandomUpgrades()
end

function upgradeMenu.hide()
    upgradeMenu.isExiting = true
    upgradeMenu.isAnimating = true

    upgradeMenu.targetY = upgradeMenu.config.startY
end

function upgradeMenu.update(dt)
    if not upgradeMenu.visible then return end
    
    upgradeMenu.wiggleTime = upgradeMenu.wiggleTime + dt * upgradeMenu.config.iconWiggle.speed
    
    if upgradeMenu.isAnimating then
        local speed = upgradeMenu.isExiting and upgradeMenu.config.exitSpeed or upgradeMenu.config.slideSpeed
        upgradeMenu.y = utils.lerp(upgradeMenu.y, upgradeMenu.targetY, dt * speed)
        
        if upgradeMenu.isExiting then
            if upgradeMenu.y <= upgradeMenu.config.startY + 10 then
                upgradeMenu.visible = false
                upgradeMenu.isAnimating = false
                upgradeMenu.isExiting = false
                upgradeMenu.y = upgradeMenu.config.startY
                
                gameState.paused = false
                gameState.pausedForUpgrade = false
            end
        else
            if math.abs(upgradeMenu.y - upgradeMenu.targetY) < 1 then
                upgradeMenu.y = upgradeMenu.targetY
                upgradeMenu.isAnimating = false
            end
        end
    end
    
    if not upgradeMenu.isAnimating and not upgradeMenu.isExiting then
        local scaledX, scaledY = input.getMousePosition()
        
        local popupX = (config.screen.width - upgradeMenu.width) / 2
        local popupY = upgradeMenu.y
        
        local previousHoverIndex = upgradeMenu.hoverIndex
        upgradeMenu.hoverIndex = nil
        
        for i = 1, #upgradeMenu.randomUpgrades do
            local upgradeY = popupY + 16 + ((i - 1) * upgradeMenu.config.upgradeHeight)
            local upgradeBottom = upgradeY + upgradeMenu.config.upgradeHeight
            
            if scaledX >= popupX and 
               scaledX <= popupX + upgradeMenu.width and
               scaledY >= upgradeY and 
               scaledY < upgradeBottom then
                upgradeMenu.hoverIndex = i
                break
            end
        end
        
        for i = 1, #upgradeMenu.randomUpgrades do
            if upgradeMenu.textAnimationStates[i] then
                local state = upgradeMenu.textAnimationStates[i]
                if upgradeMenu.hoverIndex == i then
                    state.targetX = upgradeMenu.config.textShift.x
                    state.targetY = upgradeMenu.config.textShift.y
                else
                    state.targetX = 0
                    state.targetY = 0
                end
            end
        end
    end
    
    for i, state in ipairs(upgradeMenu.textAnimationStates) do
        state.actualX = utils.lerp(state.actualX, state.targetX, dt * upgradeMenu.config.textShift.animationSpeed)
        state.actualY = utils.lerp(state.actualY, state.targetY, dt * upgradeMenu.config.textShift.animationSpeed)
    end
end

function upgradeMenu.draw()
    if not upgradeMenu.visible then return end
    
    local popupX = (config.screen.width - upgradeMenu.width) / 2
    local popupY = upgradeMenu.y
    
    love.graphics.setColor(upgradeMenu.shadowColor)
    love.graphics.draw(upgradeMenu.popup, popupX + upgradeMenu.config.popupShadow.x, popupY + upgradeMenu.config.popupShadow.y)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(upgradeMenu.popup, popupX, popupY)
    
    if not upgradeMenu.isExiting then
        love.graphics.setColor(1, 1, 1)
        
        local upgradeY = popupY + upgradeMenu.config.upgradesTopPadding
        for i, upgrade in ipairs(upgradeMenu.randomUpgrades) do
            local animState = upgradeMenu.textAnimationStates[i]
            local shiftX = animState and animState.actualX or 0
            local shiftY = animState and animState.actualY or 0
            
            local iconX = popupX + upgradeMenu.config.iconXOffset
            local iconY = upgradeY
            local rotation = 0
            local iconWidth = upgrade.image:getWidth()
            local iconHeight = upgrade.image:getHeight()
            local iconCenterX = iconWidth / 2
            local iconCenterY = iconHeight / 2
            if animState then
                rotation = math.sin(upgradeMenu.wiggleTime) * upgradeMenu.config.iconWiggle.maxRotation * 
                           (upgradeMenu.hoverIndex == i and 1 or 0)
            end
            if upgradeMenu.hoverIndex == i then
                love.graphics.setColor(upgradeMenu.shadowColor)
                love.graphics.draw(
                    upgrade.image,
                    iconX + shiftX + iconCenterX + upgradeMenu.config.iconShadow.x,
                    iconY + shiftY + iconCenterY + upgradeMenu.config.iconShadow.y,
                    rotation,
                    1, 1,
                    iconCenterX, iconCenterY
                )
            end
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(
                upgrade.image,
                iconX + shiftX + iconCenterX,
                iconY + shiftY + iconCenterY,
                rotation,
                1, 1,
                iconCenterX, iconCenterY
            )
            
            local shiftX = animState and animState.actualX or 0
            local shiftY = animState and animState.actualY or 0
            local titleShadowOffset = (upgradeMenu.hoverIndex == i) and upgradeMenu.config.textShift.titleShadow or 0
            local descShadowOffset = (upgradeMenu.hoverIndex == i) and upgradeMenu.config.textShift.descShadow or 0
            
            love.graphics.setFont(assets.fonts.fat)
            love.graphics.setColor(upgradeMenu.shadowColor)
            love.graphics.print(upgrade.name, popupX + upgradeMenu.config.textXOffset + shiftX + titleShadowOffset,
                                               upgradeY + shiftY + titleShadowOffset)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(upgrade.name, popupX + upgradeMenu.config.textXOffset + shiftX,
                                               upgradeY + shiftY)
            
            love.graphics.setFont(assets.fonts.m5x7)
            love.graphics.setColor(upgradeMenu.shadowColor)
            love.graphics.print(upgrade.description, popupX + upgradeMenu.config.textXOffset + shiftX + descShadowOffset,
                                              upgradeY + upgradeMenu.config.descriptionYOffset + shiftY + descShadowOffset)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(upgrade.description, popupX + upgradeMenu.config.textXOffset + shiftX,
                                              upgradeY + upgradeMenu.config.descriptionYOffset + shiftY)
            
            upgradeY = upgradeY + upgradeMenu.config.upgradeHeight
        end
    end
end

function upgradeMenu.mousepressed(x, y, button)
    if not upgradeMenu.visible or upgradeMenu.isAnimating or upgradeMenu.isExiting then 
        return false
    end
    
    if upgradeMenu.hoverIndex then
        local upgrade = upgradeMenu.randomUpgrades[upgradeMenu.hoverIndex]
        local upgradeName = upgrade.name

        print("Selected upgrade: " .. upgradeName)

        if upgrade.effect then
            upgrade.effect()
        end

        upgradeMenu.hide()
        return true
    end
    
    return false
end

return upgradeMenu
