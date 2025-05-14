local upgradeList = {}

local config = require("src.config")
local assets = require("src.assets")
local utils = require("src.utils")
local input = require("src.input")

upgradeList.config = {
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
    iconShadow = { x = 2, y = 2 },
    iconXOffset = 12,
    textXOffset = 42,
    upgradesTopPadding = 16,
    descriptionYOffset = 12,
}

function upgradeList.new(options)
    local instance = {}
    
    options = options or {}
    
    instance.upgrades = options.upgrades or {}
    instance.shadowColor = options.shadowColor or assets.shadowColor
    instance.randomUpgrades = {}
    instance.hoverIndex = nil
    instance.wiggleTime = 0
    instance.textAnimationStates = {}
    instance.onSelect = options.onSelect
    
    function instance:getRandomUpgrades()
        local shuffled = {}
        for _, upgrade in ipairs(self.upgrades) do
            table.insert(shuffled, upgrade)
        end
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        
        self.textAnimationStates = {}
        for i = 1, math.min(3, #shuffled) do
            self.textAnimationStates[i] = {
                actualX = 0,
                actualY = 0,
                targetX = 0,
                targetY = 0
            }
        end
        
        local numToShow = math.min(3, #shuffled)
        local result = {}
        for i = 1, numToShow do
            table.insert(result, shuffled[i])
        end
        
        self.randomUpgrades = result
        return result
    end
    
    function instance:update(dt, popupX, popupY, popupWidth)
        self.wiggleTime = self.wiggleTime + dt * upgradeList.config.iconWiggle.speed
        
        local scaledX, scaledY = input.getMousePosition()
        
        local previousHoverIndex = self.hoverIndex
        self.hoverIndex = nil
        
        for i = 1, #self.randomUpgrades do
            local upgradeY = popupY + upgradeList.config.upgradesTopPadding + ((i - 1) * upgradeList.config.upgradeHeight)
            local upgradeBottom = upgradeY + upgradeList.config.upgradeHeight
            
            if scaledX >= popupX and 
               scaledX <= popupX + popupWidth and
               scaledY >= upgradeY and 
               scaledY < upgradeBottom then
                self.hoverIndex = i
                break
            end
        end
        
        for i = 1, #self.randomUpgrades do
            if self.textAnimationStates[i] then
                local state = self.textAnimationStates[i]
                if self.hoverIndex == i then
                    state.targetX = upgradeList.config.textShift.x
                    state.targetY = upgradeList.config.textShift.y
                else
                    state.targetX = 0
                    state.targetY = 0
                end
                
                state.actualX = utils.lerp(state.actualX, state.targetX, 
                                        dt * upgradeList.config.textShift.animationSpeed)
                state.actualY = utils.lerp(state.actualY, state.targetY, 
                                        dt * upgradeList.config.textShift.animationSpeed)
            end
        end
    end
    
    function instance:draw(popupX, popupY)
        local upgradeY = popupY + upgradeList.config.upgradesTopPadding
        
        for i, upgrade in ipairs(self.randomUpgrades) do
            local animState = self.textAnimationStates[i]
            local shiftX = animState and animState.actualX or 0
            local shiftY = animState and animState.actualY or 0
            
            local iconX = popupX + upgradeList.config.iconXOffset
            local iconY = upgradeY
            local rotation = 0
            local iconWidth = upgrade.image:getWidth()
            local iconHeight = upgrade.image:getHeight()
            local iconCenterX = iconWidth / 2
            local iconCenterY = iconHeight / 2
            
            if animState then
                rotation = math.sin(self.wiggleTime) * upgradeList.config.iconWiggle.maxRotation * 
                           (self.hoverIndex == i and 1 or 0)
            end
            
            if self.hoverIndex == i then
                utils.drawWithShadow(
                    upgrade.image,
                    iconX + shiftX + iconCenterX,
                    iconY + shiftY + iconCenterY,
                    rotation,
                    1, 1,
                    iconCenterX, iconCenterY,
                    upgradeList.config.iconShadow.x,
                    self.shadowColor
                )
            else
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(
                    upgrade.image,
                    iconX + shiftX + iconCenterX,
                    iconY + shiftY + iconCenterY,
                    rotation,
                    1, 1,
                    iconCenterX, iconCenterY
                )
            end
            
            local titleShadowOffset = (self.hoverIndex == i) and upgradeList.config.textShift.titleShadow or 0
            local descShadowOffset = (self.hoverIndex == i) and upgradeList.config.textShift.descShadow or 0
            
            love.graphics.setFont(assets.fonts.fat)
            
            love.graphics.setColor(self.shadowColor)
            love.graphics.print(upgrade.name, 
                               popupX + upgradeList.config.textXOffset + shiftX + titleShadowOffset,
                               upgradeY + shiftY + titleShadowOffset)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(upgrade.name, 
                               popupX + upgradeList.config.textXOffset + shiftX,
                               upgradeY + shiftY)
            
            love.graphics.setFont(assets.fonts.m5x7)
            
            love.graphics.setColor(self.shadowColor)
            love.graphics.print(upgrade.description, 
                              popupX + upgradeList.config.textXOffset + shiftX + descShadowOffset,
                              upgradeY + upgradeList.config.descriptionYOffset + shiftY + descShadowOffset)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(upgrade.description, 
                              popupX + upgradeList.config.textXOffset + shiftX,
                              upgradeY + upgradeList.config.descriptionYOffset + shiftY)
            
            upgradeY = upgradeY + upgradeList.config.upgradeHeight
        end
    end
    
    function instance:mousepressed(x, y, button)
        if self.hoverIndex then
            local upgrade = self.randomUpgrades[self.hoverIndex]
            
            if self.onSelect then
                self.onSelect(upgrade)
            end
            
            return true
        end
        
        return false
    end
    
    return instance
end

return upgradeList