local State = require "state"
local Button = require "button"

state = State:new()
restart_button = Button:new({
    x = 300,
    y = 250,
    width = 200,
    height = 100,
    text = "Restart"
})

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.window.setFullscreen(true)
end

function love.update(dt)
    if state.game_over then
        return -- Stop updating if the game is over
    end

    state.time_elapsed = state.time_elapsed + dt -- Update elapsed time

    state:decrease_spawn_interval()
    state:update_dash_cooldown(dt)

    local player, enemies = state.player, state.enemies

    -- Handle dashing logic
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

    -- Update enemies
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
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
                table.remove(enemies, i)                -- Remove enemy if hit during dash
                state.kill_count = state.kill_count + 1 -- Increase kill count
            end
        else
            -- Check collision with player (game over condition)
            local dist_to_player = math.sqrt((player.x - enemy.x) ^ 2 + (player.y - enemy.y) ^ 2)
            if dist_to_player < player.radius + enemy.radius then
                state.game_over = true
                if state.kill_count > state.max_kills then
                    state.max_kills = state.kill_count -- Update max kills if current is higher
                end
            end
        end
    end

    -- Handle enemy spawning
    state.enemy_spawn_timer = state.enemy_spawn_timer + dt
    if state.enemy_spawn_timer >= state.spawn_interval then
        state.enemy_spawn_timer = 0
        local new_enemy = {
            x = math.random(player.radius, love.graphics.getWidth() - player.radius),
            y = math.random(player.radius, love.graphics.getHeight() - player.radius),
            radius = 15,
            color = { 1, 0, 0 }
        }
        table.insert(enemies, new_enemy)
    end

    state.player, state.enemies = player, enemies
end

function love.keypressed(key)
    state.player:attack(key, state)
end

function love.mousepressed(x, y, button)
    if state.game_over and button == 1 then
        if restart_button:clicked(x, y) then
            state:restart()
        end
    end
end

function love.draw()
    if state.game_over then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game Over", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.printf("Max Kills: " .. state.max_kills, 0, 250, love.graphics.getWidth(), "center")
        restart_button:draw()
        return
    end

    state.player:draw()

    -- Draw enemies
    for _, enemy in ipairs(state.enemies) do
        love.graphics.setColor(enemy.color)
        love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
    end

    -- Draw kill count
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Kills: " .. state.kill_count, 10, 10, love.graphics.getWidth(), "left")
end
