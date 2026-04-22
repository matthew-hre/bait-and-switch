local particle = {}

local assets = require("src.assets")
local config = require("src.config")
local gameState = require("src.gameState")
local utils = require("src.utils")

particle.config = {
    defaultScale = 0.5,
    defaultScaleDecay = 0.5,
    defaultRotation = 0,
    defaultVelocity = {x = 0, y = 0},
    defaultColor = {1, 1, 1, 1} 
}

particle.active = {}

function particle.load()
    particle.shadowColor = assets.shadowColor
    particle.shadowOffset = config.visual.shadowOffset
end

function particle.create(x, y, sprite, options)
    options = options or {}
    
    local p = {}
    p.x = x
    p.y = y
    p.sprite = sprite
    p.ox = sprite:getWidth() / 2
    p.oy = sprite:getHeight() / 2
    p.scale = options.scale or particle.config.defaultScale
    p.scaleDecay = options.scaleDecay or particle.config.defaultScaleDecay
    p.angle = options.angle or 0
    p.rotation = options.rotation or particle.config.defaultRotation
    p.vx = options.vx or particle.config.defaultVelocity.x
    p.vy = options.vy or particle.config.defaultVelocity.y
    p.shadowOffset = options.shadowOffset or particle.shadowOffset
    p.shadowColor = options.shadowColor
    p.color = options.color or particle.config.defaultColor
    
    table.insert(particle.active, p)
    return p
end

function particle.update(dt)
    if gameState.isPaused() then
        return
    end
    
    local n = #particle.active
    local i = 1
    while i <= n do
        local p = particle.active[i]
        
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        
        if p.rotation ~= 0 then
            p.angle = p.angle + p.rotation * dt
        end
        
        p.scale = p.scale - p.scaleDecay * dt
        
        if p.scale <= 0 then
            particle.active[i] = particle.active[n]
            particle.active[n] = nil
            n = n - 1
        else
            i = i + 1
        end
    end
end

function particle.draw()
    local floor = math.floor
    local shadowColor = particle.shadowColor
    
    for _, p in ipairs(particle.active) do
        local px = floor(p.x)
        local py = floor(p.y)
        local sprite = p.sprite
        local ox = p.ox
        local oy = p.oy
        local scale = p.scale
        local angle = p.angle
        local shadowOffset = p.shadowOffset * scale
        
        local tint = nil
        if p.color[1] ~= 1 or p.color[2] ~= 1 or p.color[3] ~= 1 or p.color[4] ~= 1 then
            tint = p.color
        end
        
        utils.drawWithShadow(
            sprite, 
            px, 
            py, 
            angle, 
            scale, 
            scale, 
            ox, 
            oy,
            shadowOffset,
            p.shadowColor or shadowColor,
            tint
        )
    end
end

return particle
