local popup = {}

local config = require("src.config")
local assets = require("src.assets")
local utils = require("src.utils")

popup.config = {
    slideSpeed = 5,
    startY = -200,
    exitSpeed = 7,
    popupShadow = { x = 2, y = 2 }
}

function popup.new(options)
    local instance = {}
    
    options = options or {}
    
    instance.sprite = options.sprite or assets.ui.popup
    instance.shadowColor = options.shadowColor or assets.shadowColor
    instance.visible = false
    instance.isAnimating = false
    instance.isExiting = false
    instance.y = popup.config.startY
    instance.targetY = 0
    instance.width = instance.sprite:getWidth()
    instance.height = instance.sprite:getHeight()
    instance.onHideComplete = options.onHideComplete
    
    function instance:show()
        if self.visible then return end
        
        self.visible = true
        self.isAnimating = true
        self.isExiting = false
        self.y = popup.config.startY
        
        self.targetY = (config.screen.height - self.height) / 2
        
        if options.onShow then
            options.onShow()
        end
    end
    
    function instance:hide()
        self.isExiting = true
        self.isAnimating = true
        self.targetY = popup.config.startY
    end
    
    function instance:update(dt)
        if not self.visible then return end
        
        if self.isAnimating then
            local speed = self.isExiting and popup.config.exitSpeed or popup.config.slideSpeed
            self.y = utils.lerp(self.y, self.targetY, dt * speed)
            
            if self.isExiting then
                if self.y <= popup.config.startY + 10 then
                    self.visible = false
                    self.isAnimating = false
                    self.isExiting = false
                    self.y = popup.config.startY
                    
                    if self.onHideComplete then
                        self.onHideComplete()
                    end
                end
            else
                if math.abs(self.y - self.targetY) < 1 then
                    self.y = self.targetY
                    self.isAnimating = false
                end
            end
        end
    end
    
    function instance:draw()
        if not self.visible then return end
        
        local popupX = (config.screen.width - self.width) / 2
        local popupY = self.y
        
        utils.drawWithShadow(
            self.sprite, 
            popupX, 
            popupY, 
            0, 
            1, 
            1, 
            0, 
            0, 
            popup.config.popupShadow.x, 
            self.shadowColor
        )
        
        if not self.isExiting and options.drawContent then
            options.drawContent(self, popupX, popupY)
        end
    end
    
    function instance:getPosition()
        local popupX = (config.screen.width - self.width) / 2
        return popupX, self.y
    end
    
    function instance:isActive()
        return self.visible and not self.isAnimating and not self.isExiting
    end
    
    return instance
end

return popup