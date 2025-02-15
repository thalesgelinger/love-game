local Player = require "player"

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
--- @field enemies Player[] the enemies
--- @field enemy_spawn_timer number Timer to control enemy spawning
--- @field time_elapsed number Tracks time elapsed since game start

--- @class State: StateProps
local State = {}
State.__index = State

function State:make_enemies()
    local enemies = {
        Player:new(),
        Player:new(),
    }
    enemies[1].x = 200
    enemies[1].y = 200
    enemies[1].color = { 1, 0, 0 }
    enemies[2].x = 400
    enemies[2].y = 600
    enemies[2].color = { 1, 0, 0 }
    return enemies
end

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
        enemies = self:make_enemies(),
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

function State:add_new_enemy()
    self.enemy_spawn_timer = 0
    local new_enemy = Player:new()
    new_enemy.x = math.random(self.player.radius, love.graphics.getWidth() - self.player.radius)
    new_enemy.y = math.random(self.player.radius, love.graphics.getHeight() - self.player.radius)
    new_enemy.color = { 1, 0, 0 }

    table.insert(self.enemies, new_enemy)
end

function State:handle_dash(dt)
    local player = self.player

    if player.is_dashing then
        player.dash_timer = player.dash_timer - dt
        if player.dash_timer <= 0 then
            player.is_dashing = false
        else
            player.x = player.x + player.dx * player.speed * 3 * dt
            player.y = player.y + player.dy * player.speed * 3 * dt
        end
    else
        -- Movement controls
        local dx, dy = 0, 0
        if love.keyboard.isDown("w") then dy = -1 end
        if love.keyboard.isDown("s") then dy = 1 end
        if love.keyboard.isDown("a") then dx = -1 end
        if love.keyboard.isDown("d") then dx = 1 end

        -- Normalize diagonal movement
        local magnitude = math.sqrt(dx * dx + dy * dy)
        if magnitude > 0 then
            dx, dy = dx / magnitude, dy / magnitude
        end

        player.dx, player.dy = dx, dy

        player.x = player.x + dx * player.speed * dt
        player.y = player.y + dy * player.speed * dt
    end

    -- Prevent player from going off-screen
    player.x = math.max(player.radius, math.min(love.graphics.getWidth() - player.radius, player.x))
    player.y = math.max(player.radius, math.min(love.graphics.getHeight() - player.radius, player.y))

    self.player = player
end

function State:update_enemies(dt)
    local player = self.player

    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        local ex, ey = enemy.x, enemy.y
        local dx, dy = player.x - ex, player.y - ey
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance > 0 then
            dx, dy = dx / distance, dy / distance
            enemy.x = enemy.x + dx * 100 * dt -- Enemy speed
            enemy.y = enemy.y + dy * 100 * dt
        end

        -- Check collision with player dash
        if player.is_dashing then
            local dist_to_enemy = math.sqrt((player.x - enemy.x) ^ 2 + (player.y - enemy.y) ^ 2)
            if dist_to_enemy < player.radius + enemy.radius then
                table.remove(self.enemies, i)         -- Remove enemy if hit during dash
                self.kill_count = self.kill_count + 1 -- Increase kill count
            end
        else
            -- Check collision with player (game over condition)
            local dist_to_player = math.sqrt((player.x - enemy.x) ^ 2 + (player.y - enemy.y) ^ 2)
            if dist_to_player < player.radius + enemy.radius then
                self.game_over = true
                if self.kill_count > self.max_kills then
                    self.max_kills = self.kill_count
                end
            end
        end
    end
end

function State:restart()
    self.game_over = false
    self.enemy_spawn_timer = 0
    self.spawn_interval = 2
    self.time_elapsed = 0
    self.kill_count = 0
    self.player:restart()
    self.enemies = self:make_enemies()
end

return State
