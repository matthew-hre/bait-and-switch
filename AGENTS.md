# Bait and Switch — Agent Guide

## Project Overview

A bug-catching arcade game built with [LÖVE](https://love2d.org/) (Lua). Player controls a character with a net, catches bugs, fires them as projectiles, and progresses through waves with upgrade choices between rounds. Pixel-art style with a 256x192 internal resolution scaled up to the window.

## Commands

### Run
```bash
love .                  # Run the game (requires LÖVE 11.5)
```

### Dev Shell (Nix)
```bash
direnv allow            # Enter dev shell (provides love, lua, stylua)
```

### Format
```bash
stylua src/             # Format Lua source files
```
No stylua config file exists, so it uses default settings.

### Build / Release
Pushing a git tag triggers the GitHub Actions workflow (`.github/workflows/release.yml`), which uses `nhartland/love-build@v1` to produce Windows/macOS/Linux/app bundles. No manual build step needed for development.

### Save Data
Persisted via `love.filesystem` at the identity `baitandswitch` (set in `conf.lua`). Save file is `savedata.lua` containing best wave and settings. On Linux this lives at `~/.local/share/love/baitandswitch/`.

## Architecture

### Entry Point
`main.lua` → `require("src.main")`. The `conf.lua` sets the save identity.

### State Machine (`src/gameState.lua`)
The game uses a string-based state machine. All states are UPPER_CASE constants stored in `gameState.current`. The main loop in `src/main.lua` dispatches update, draw, and mouse events through lookup tables (`stateUpdate`, `stateDraw`, `stateMousepressed`) keyed by state name.

**States:**
- `MAIN_MENU` — title screen
- `MAIN_MENU_SETTINGS` — settings from main menu
- `MENU_TO_PLAY` — fade transition into gameplay
- `PLAYING` — active gameplay
- `PAUSED_MENU` — pause overlay
- `PAUSED_SETTINGS` — settings from pause menu
- `PAUSED_UPGRADE` — wave-complete upgrade selection
- `DEATH_ANIMATING` — particle death animation, no input
- `DEATH_SCREEN` — game over text reveal, auto-restarts after delay

### Rendering Pipeline
Everything draws to an offscreen canvas at 256x192 (`config.screen.width/height`), then the canvas is scaled to the window. In fullscreen or non-4x modes, letterboxing is calculated and stored in `gameState.display` (scale, offsetX, offsetY). The input system uses these values to convert mouse coordinates from screen space to game space.

### Module Pattern
Every module (`src/player.lua`, `src/enemy.lua`, etc.) is a plain table with functions attached. No classes, no OOP. Each module exports itself via `return`. Most follow this lifecycle:
1. `module.load()` — called once from `love.load`, sets up initial state, caches config values, caches sprite references
2. `module.update(dt)` — called every frame
3. `module.draw()` — called every frame
4. `module.mousepressed(x, y, button)` — event handler

Two modules use a factory pattern (return instances via `.new()`): `src/ui/popup.lua` and `src/ui/upgradeList.lua`. These use colon-syntax methods on instance tables.

### Entity Management
Entities (enemies, projectiles, particles) are stored in arrays (`enemy.active`, `projectile.active`, `particle.active`). Dead entities are removed via **swap-and-pop** (not splice), iterating with a while-loop pattern:
```lua
local n = #list
local i = 1
while i <= n do
    local item = list[i]
    if item.dead then
        list[i] = list[n]
        list[n] = nil
        n = n - 1
    else
        i = i + 1
    end
end
```

### Sound System
Sounds use a **pooling pattern** (`assets.playSound`) to allow overlapping playback. Each source is cloned into a pool of 8 instances, indexed round-robin. All sounds are loaded as `"static"` sources. Pitch variance is supported via an optional second argument.

### Input System (`src/input.lua`)
- Tracks three states: `buttonsDown`, `buttonsPressed`, `buttonsReleased`
- `buttonsPressed`/`buttonsReleased` are cleared every frame via `input.clear()` (called after `stateUpdate`)
- Actions map to either mouse buttons (number) or keys (string)
- Mouse coordinates are converted to game-space in `input.update()` using `screenScale`, `screenOffsetX`, `screenOffsetY`
- Always use `input.getMousePosition()` (scaled), never raw `love.mouse.getPosition()`

### Save System (`src/save.lua`)
Serializes tables to Lua source and writes via `love.filesystem`. Read back by loading as a chunk. Used for: best wave score, settings (scale, fullscreen, volume, muted, net position).

## Key Files

| File | Purpose |
|------|---------|
| `src/main.lua` | Root game loop, LÖVE callbacks, state dispatch, rendering pipeline |
| `src/gameState.lua` | Global state: current state, stats, settings, death screen timers |
| `src/config.lua` | Screen dimensions, visual settings, control bindings |
| `src/assets.lua` | All image/font/audio loading, sound pooling, color constants |
| `src/input.lua` | Input abstraction layer with action mapping |
| `src/player.lua` | Player movement, health, invincibility, death particles |
| `src/enemy.lua` | Spawning, movement (chase player + separation), collision, wave kills |
| `src/net.lua` | Net swing animation, catch detection, loaded state |
| `src/projectile.lua` | Fired bugs, wall bouncing, enemy hit detection, trail particles |
| `src/particle.lua` | Generic particle system (death effects, projectile trails) |
| `src/utils.lua` | `lerp`, `drawWithShadow` (shadow + sprite in one call) |
| `src/ui/popup.lua` | Reusable slide-in/out popup component (factory pattern) |
| `src/ui/upgradeList.lua` | Upgrade selection list with hover animations (factory pattern) |

## Conventions & Patterns

- **Shadow rendering**: Nearly everything uses `utils.drawWithShadow()` which draws the sprite offset by `shadowOffset` in `shadowColor`, then draws the sprite normally. The shadow color is a consistent blue `{0, 105/255, 170/255, 1}`.
- **Angle snapping**: Rotations are snapped to a grid via `math.floor(angle * snapFactor) / snapFactor` for a chunky pixel-art feel.
- **Coordinates**: Pixel positions are floored with `math.floor()` before drawing to prevent sub-pixel rendering artifacts.
- **Performance**: Hot loops cache locals for `math.sqrt`, `math.floor`, `ipairs`, `math.cos`, `math.sin`, and `math.atan2` at the top of update/draw functions.
- **Tuning constants**: Each module has a `.config` table at the top containing all magic numbers (speeds, sizes, delays, particle ranges). Never hardcode tuning values inline.
- **Lazy requires**: Some modules use `require()` inside functions (e.g., `player.takeDamage` requires `ui`, `net`, `enemy`, `deathScreen`, `projectile` locally) to break circular dependency chains. These are always at the top of the function, never in conditional branches.

## Gotchas

- **Circular dependencies**: Several modules require each other (`player ↔ enemy ↔ net`, `player → ui`, etc.). The project handles this with lazy requires inside function bodies. When adding cross-module calls, prefer placing `require()` at function scope rather than module scope.
- **Swap-and-pop ordering**: When iterating entities during update, modification order matters. The while-loop with decrement is the canonical pattern — don't use `for` loops with `ipairs` when removal is possible.
- **State transitions set `gameState.current` directly**: There's no transition queue or guard. Setting `gameState.current` to a new state takes effect on the next frame. Be careful about setting state inside an update that's already dispatched for that state.
- **`DEATH_ANIMATING` still updates particles and projectiles**: But not enemies or player. The death screen state auto-transitions to `DEATH_SCREEN` after a timer.
- **Tutorial mode**: `gameState.tutorialMode` suppresses enemy spawning but doesn't prevent enemies from being in the active list. The tutorial creates a single `isTutorialBug` enemy that skips the normal movement code path.
- **`input.clear()` timing**: Pressed/released states are cleared after the state update runs, so they're only valid during the current frame's update cycle.
- **No `.stylua.toml`**: Running `stylua` without config uses defaults. The codebase appears to follow stylua defaults (4-space indent, spaces around operators).
- **Display scaling**: When changing resolution in settings, `gameState.display` and `input.screenScale/screenOffsetX/screenOffsetY` must all be updated together (see `settingsMenu.applyDisplay()`). Mouse input will be wrong if these get out of sync.
