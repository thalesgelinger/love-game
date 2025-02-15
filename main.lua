local Player = require "player"
local State = require "state"
local Button = require "button"
-- Load the Love2D framework

time_elapsed = 0 -- Tracks time elapsed since game start


state = State:new()
player = Player:new()
restart_button = Button:new({
    x = 300,
    y = 250,
    width = 200,
    height = 100,
    text = "Restart"
})

enemies = {
    { x = 200, y = 200, radius = 15, color = { 1, 0, 0 } }, -- red
    { x = 600, y = 400, radius = 15, color = { 1, 0, 0 } }
}

enemy_spawn_timer = 0 -- Timer to control enemy spawning

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.window.setFullscreen(true)
end

function love.update(dt)
    if game_over then
        return -- Stop updating if the game is over
    end

    time_elapsed = time_elapsed + dt -- Update elapsed time

    -- Decrease spawn interval over time
    if time_elapsed >= 10 and spawn_interval > spawn_min_interval then
        spawn_interval = math.max(spawn_min_interval, spawn_interval - spawn_decrease_rate)
        time_elapsed = 0
    end

    -- Update dash cooldown timer
    if player.dash_cooldown_timer > 0 then
        player.dash_cooldown_timer = player.dash_cooldown_timer - dt
    end

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
                table.remove(enemies, i)    -- Remove enemy if hit during dash
                kill_count = kill_count + 1 -- Increase kill count
            end
        else
            -- Check collision with player (game over condition)
            local dist_to_player = math.sqrt((player.x - enemy.x) ^ 2 + (player.y - enemy.y) ^ 2)
            if dist_to_player < player.radius + enemy.radius then
                game_over = true
                if kill_count > max_kills then
                    max_kills = kill_count -- Update max kills if current is higher
                end
            end
        end
    end

    -- Handle enemy spawning
    enemy_spawn_timer = enemy_spawn_timer + dt
    if enemy_spawn_timer >= spawn_interval then
        enemy_spawn_timer = 0
        local new_enemy = {
            x = math.random(player.radius, love.graphics.getWidth() - player.radius),
            y = math.random(player.radius, love.graphics.getHeight() - player.radius),
            radius = 15,
            color = { 1, 0, 0 }
        }
        table.insert(enemies, new_enemy)
    end
end

function love.keypressed(key)
    if key == "k" and not player.is_dashing and player.dash_cooldown_timer <= 0 and not game_over then
        player.is_dashing = true
        player.dash_timer = dash_duration
        player.dash_cooldown_timer = dash_cooldown
    end
end

function love.mousepressed(x, y, button)
    if game_over and button == 1 then
        if x > restart_button.x and x < restart_button.x + restart_button.width and y > restart_button.y and y < restart_button.y + restart_button.height then
            restart_game()
        end
    end
end

function restart_game()
    game_over = false
    player.x = 400
    player.y = 300
    player.is_dashing = false
    player.dash_timer = 0
    player.dash_cooldown_timer = 0
    enemies = {
        { x = 200, y = 200, radius = 15, color = { 1, 0, 0 } },
        { x = 600, y = 400, radius = 15, color = { 1, 0, 0 } }
    }
    enemy_spawn_timer = 0
    spawn_interval = 2 -- Reset spawn interval
    time_elapsed = 0   -- Reset elapsed time
    kill_count = 0     -- Reset kill count
end

function love.draw()
    if game_over then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game Over", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.printf("Max Kills: " .. max_kills, 0, 250, love.graphics.getWidth(), "center")
        love.graphics.rectangle("fill", restart_button.x, restart_button.y, restart_button.width, restart_button.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(restart_button.text, restart_button.x, restart_button.y + restart_button.height / 2 - 10,
            restart_button.width, "center")
        return
    end

    player:draw()

    -- Draw enemies
    for _, enemy in ipairs(enemies) do
        love.graphics.setColor(enemy.color)
        love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
    end

    -- Draw kill count
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Kills: " .. kill_count, 10, 10, love.graphics.getWidth(), "left")
end
