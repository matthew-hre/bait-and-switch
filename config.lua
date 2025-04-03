local config = {
    screen = {
        width = 256,
        height = 192,
        scale = 4
    },
    
    visual = {
        shadowColor = {0, 105/255, 170/255, 1},
        shadowOffset = 3,
        angleSnapFactor = 16
    },
    
    game = {
        title = "Bait and Switch (LÖVE)",
    },

    settings = {
        netPosition = "left",
    },
    
    controls = {
        movement = {
            up = {"up", "w"},
            down = {"down", "s"},
            left = {"left", "a"},
            right = {"right", "d"}
        },
        
        action = {
            net = 1  -- lmb
        }
    }
}

config.window = {
    width = config.screen.width * config.screen.scale,
    height = config.screen.height * config.screen.scale
}

return config
