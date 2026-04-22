local speedyBug = {}

local config = require("src.config")
local assets = require("src.assets")
local player = require("src.player")
local particle = require("src.particle")
local gameState = require("src.gameState")
local utils = require("src.utils")

speedyBug.config = {
    minWave = 5,
    spawnChance = 0.1,
    spawnDelayMin = 1.0,
    spawnDelayMax = 3.0,

    speed = 115,
    spinSpeed = 6,

    sineAmplitude = 18,
    sineFrequency = 6,

    minSegments = 3,
    maxSegments = 6,
    segmentSpacing = 6,
    segmentRotationStagger = 0.4,

    margin = 20,

    particleDelay = 0.04,
    particle = {
        minScale = 0.2,
        maxScale = 0.5,
        minScaleDecay = 0.6,
        maxScaleDecay = 1.2,
        maxRotationSpeed = 4,
        maxVelocity = 30,
    },
}

speedyBug.active = {}
speedyBug.pending = {}

function speedyBug.load()
    speedyBug.sprite = assets.enemySprite
    speedyBug.shadowColor = assets.speedyBugShadowColor
    speedyBug.color = assets.speedyBugColor

    speedyBug.screenWidth = config.screen.width
    speedyBug.screenHeight = config.screen.height
    speedyBug.shadowOffset = config.visual.shadowOffset
    speedyBug.angleSnapFactor = config.visual.angleSnapFactor

    speedyBug.spriteOX = speedyBug.sprite:getWidth() / 2
    speedyBug.spriteOY = speedyBug.sprite:getHeight() / 2
end

function speedyBug.scheduleSpawn()
    local delay = math.random() *
        (speedyBug.config.spawnDelayMax - speedyBug.config.spawnDelayMin) +
        speedyBug.config.spawnDelayMin
    table.insert(speedyBug.pending, delay)
end

function speedyBug.createBug()
    local b = {}

    local playerOnLeft = player.x < speedyBug.screenWidth / 2
    if playerOnLeft then
        b.x = speedyBug.screenWidth + speedyBug.config.margin
    else
        b.x = -speedyBug.config.margin
    end
    b.y = math.random(speedyBug.config.margin, speedyBug.screenHeight - speedyBug.config.margin)

    local dx = player.x - b.x
    local dy = player.y - b.y
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx, dy = dx / len, dy / len
    end

    -- forward direction (toward player)
    b.dirX = dx
    b.dirY = dy
    -- perpendicular direction (for sine wave)
    b.perpX = -dy
    b.perpY = dx

    b.baseX = b.x
    b.baseY = b.y
    b.traveled = 0
    b.angle = 0
    b.dead = false
    b.particleTimer = 0
    b.segments = math.random(speedyBug.config.minSegments, speedyBug.config.maxSegments)

    b.sound = assets.audio.speedyBugPass:clone()
    b.sound:setLooping(true)
    b.sound:setVolume(0)
    b.sound:play()

    table.insert(speedyBug.active, b)
end

function speedyBug.update(dt)
    if gameState.isPaused() then
        return
    end

    if not gameState.tutorialMode and gameState.stats.currentWave >= speedyBug.config.minWave then
        local n = #speedyBug.pending
        local i = 1
        while i <= n do
            speedyBug.pending[i] = speedyBug.pending[i] - dt
            if speedyBug.pending[i] <= 0 then
                speedyBug.createBug()
                speedyBug.pending[i] = speedyBug.pending[n]
                speedyBug.pending[n] = nil
                n = n - 1
            else
                i = i + 1
            end
        end
    end

    local sqrt = math.sqrt
    local sin = math.sin
    local random = math.random
    local screenW = speedyBug.screenWidth
    local screenH = speedyBug.screenHeight
    local margin = speedyBug.config.margin
    local playerX, playerY = player.x, player.y
    local playerRadius = player.getCollisionRadius()
    local color = speedyBug.color
    local speed = speedyBug.config.speed
    local sineAmp = speedyBug.config.sineAmplitude
    local sineFreq = speedyBug.config.sineFrequency

    local n = #speedyBug.active
    local i = 1
    while i <= n do
        local b = speedyBug.active[i]

        b.traveled = b.traveled + speed * dt
        b.angle = b.angle + speedyBug.config.spinSpeed * dt

        -- position along sine wave path
        local sineOffset = sin(b.traveled / speed * sineFreq) * sineAmp
        b.x = b.baseX + b.dirX * b.traveled + b.perpX * sineOffset
        b.y = b.baseY + b.dirY * b.traveled + b.perpY * sineOffset

        -- update sound volume: fade across full travel range including off-screen margins
        local extentMin = -margin * 3
        local extentMax = screenW + margin * 3
        local center = screenW / 2
        local halfRange = center - extentMin
        local closeness = 1 - math.abs(b.x - center) / halfRange
        if closeness < 0 then closeness = 0 end
        b.sound:setVolume(closeness * closeness)

        -- player collision
        local dx = playerX - b.x
        local dy = playerY - b.y
        local dist = sqrt(dx * dx + dy * dy)
        if dist < (speedyBug.spriteOX + playerRadius) and not player.isInvincible then
            player.takeDamage()
        end

        -- trail particles (spawn behind the last tail segment)
        b.particleTimer = b.particleTimer + dt
        if b.particleTimer >= speedyBug.config.particleDelay then
            local tailTraveled = b.traveled - b.segments * speedyBug.config.segmentSpacing
            local tailSine = sin(tailTraveled / speed * sineFreq) * sineAmp
            local tailX = b.baseX + b.dirX * tailTraveled + b.perpX * tailSine
            local tailY = b.baseY + b.dirY * tailTraveled + b.perpY * tailSine

            local scale = random() *
                (speedyBug.config.particle.maxScale - speedyBug.config.particle.minScale) +
                speedyBug.config.particle.minScale
            local scaleDecay = random() *
                (speedyBug.config.particle.maxScaleDecay - speedyBug.config.particle.minScaleDecay) +
                speedyBug.config.particle.minScaleDecay
            local rotation = (random() * 2 - 1) * speedyBug.config.particle.maxRotationSpeed
            local vx = -b.dirX * speedyBug.config.particle.maxVelocity * random()
                + (random() * 2 - 1) * speedyBug.config.particle.maxVelocity * 0.5
            local vy = -b.dirY * speedyBug.config.particle.maxVelocity * random()
                + (random() * 2 - 1) * speedyBug.config.particle.maxVelocity * 0.5

            particle.create(tailX, tailY, speedyBug.sprite, {
                scale = scale,
                scaleDecay = scaleDecay,
                rotation = rotation,
                vx = vx,
                vy = vy,
                shadowOffset = speedyBug.shadowOffset,
                shadowColor = speedyBug.shadowColor,
                color = color,
            })
            b.particleTimer = 0
        end

        -- remove if off screen
        if b.x < -margin * 3 or b.x > screenW + margin * 3
            or b.y < -margin * 3 or b.y > screenH + margin * 3 then
            b.sound:stop()
            speedyBug.active[i] = speedyBug.active[n]
            speedyBug.active[n] = nil
            n = n - 1
        else
            i = i + 1
        end
    end
end

function speedyBug.draw()
    local floor = math.floor
    local sin = math.sin
    local sprite = speedyBug.sprite
    local ox = speedyBug.spriteOX
    local oy = speedyBug.spriteOY
    local snapFactor = speedyBug.angleSnapFactor
    local shadowOffset = speedyBug.shadowOffset
    local shadowColor = speedyBug.shadowColor
    local tint = speedyBug.color
    local speed = speedyBug.config.speed
    local sineAmp = speedyBug.config.sineAmplitude
    local sineFreq = speedyBug.config.sineFrequency
    local spacing = speedyBug.config.segmentSpacing
    local stagger = speedyBug.config.segmentRotationStagger

    -- shadow pass
    love.graphics.setColor(shadowColor)
    for _, b in ipairs(speedyBug.active) do
        for s = b.segments, 1, -1 do
            local segTraveled = b.traveled - s * spacing
            local segSine = sin(segTraveled / speed * sineFreq) * sineAmp
            local sx = b.baseX + b.dirX * segTraveled + b.perpX * segSine
            local sy = b.baseY + b.dirY * segTraveled + b.perpY * segSine
            local segAngle = floor((b.angle + s * stagger) * snapFactor) / snapFactor
            love.graphics.draw(sprite, floor(sx) + shadowOffset, floor(sy) + shadowOffset, segAngle, 1, 1, ox, oy)
        end
        local headAngle = floor(b.angle * snapFactor) / snapFactor
        love.graphics.draw(sprite, floor(b.x) + shadowOffset, floor(b.y) + shadowOffset, headAngle, 1, 1, ox, oy)
    end

    -- sprite pass
    love.graphics.setColor(tint)
    for _, b in ipairs(speedyBug.active) do
        for s = b.segments, 1, -1 do
            local segTraveled = b.traveled - s * spacing
            local segSine = sin(segTraveled / speed * sineFreq) * sineAmp
            local sx = b.baseX + b.dirX * segTraveled + b.perpX * segSine
            local sy = b.baseY + b.dirY * segTraveled + b.perpY * segSine
            local segAngle = floor((b.angle + s * stagger) * snapFactor) / snapFactor
            love.graphics.draw(sprite, floor(sx), floor(sy), segAngle, 1, 1, ox, oy)
        end
        local headAngle = floor(b.angle * snapFactor) / snapFactor
        love.graphics.draw(sprite, floor(b.x), floor(b.y), headAngle, 1, 1, ox, oy)
    end
end

return speedyBug
