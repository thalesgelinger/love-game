local State = require "state"
local Button = require "button"


function love.load()
    state = State:new()
    restart_button = Button:new({
        x = 300,
        y = 250,
        width = 200,
        height = 100,
        text = "Restart"
    })
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

    state:handle_dash(dt)

    state:update_enemies(dt)

    state.enemy_spawn_timer = state.enemy_spawn_timer + dt
    if state.enemy_spawn_timer >= state.spawn_interval then
        state.enemy_spawn_timer = 0
        state:add_new_enemy()
    end
end

function love.keypressed(key)
    if key == "k" then
        state.player:attack(key, state)
    end
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
        enemy:draw()
    end

    -- Draw kill count
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Kills: " .. state.kill_count, 10, 10, love.graphics.getWidth(), "left")
end
