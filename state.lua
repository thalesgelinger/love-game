local Player = require "player"
local Enemy = require "enemy"

--- @class StateProps
--- @field dash_duration number How long the dash lasts
--- @field dash_cooldown number Cooldown between dashes
--- @field game_over boolean State over state
--- @field kill_count number Count of enemies killed
--- @field max_kills number Track the maximum kills achieved
--- @field spawn_interval number Time in seconds between spawns
--- @field spawn_decrease_rate number Decrease spawn interval by this amount every 10 seconds
--- @field spawn_min_interval number Minimum spawn interval
--- @field player Player the current player
--- @field enemies Enemy[] the enemies
--- @field enemy_spawn_timer number Timer to control enemy spawning
--- @field time_elapsed number Tracks time elapsed since game start

--- @class State: StateProps
local State = {}
State.__index = State

function State:new()
    local props = {
        dash_duration = 0.2,
        dash_cooldown = 0.5,
        game_over = false,
        kill_count = 0,
        max_kills = 0,
        spawn_interval = 2,
        spawn_decrease_rate = 0.05,
        spawn_min_interval = 0.5,
        player = Player:new(),
        time_elapsed = 0,
        enemies = {
            Enemy:new(200, 200),
            Enemy:new(600, 400),
        },
        enemy_spawn_timer = 0
    }
    local obj = setmetatable(props, State)
    return obj
end

function State:decrease_spawn_interval()
    if self.time_elapsed >= 10 and self.spawn_interval > self.spawn_min_interval then
        self.spawn_interval = math.max(self.spawn_min_interval, self.spawn_interval - self.spawn_decrease_rate)
        self.time_elapsed = 0
    end
end

function State:update_dash_cooldown(dt)
    if self.player.dash_cooldown_timer > 0 then
        self.player.dash_cooldown_timer = self.player.dash_cooldown_timer - dt
    end
end

function State:restart()
    self.game_over = false
    self.enemy_spawn_timer = 0
    self.spawn_interval = 2
    self.time_elapsed = 0
    self.kill_count = 0
    self.player:restart()
    self.enemies = {
        Enemy:new(200, 200),
        Enemy:new(600, 400),
    }
end

return State
