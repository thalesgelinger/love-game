local State = {}
State.__index = State

function State:new()
    local props = {
        dash_duration = 0.2,        -- How long the dash lasts
        dash_cooldown = 0.5,        -- Cooldown between dashes
        game_over = false,          -- State over state
        kill_count = 0,             -- Count of enemies killed
        max_kills = 0,              -- Track the maximum kills achieved
        spawn_interval = 2,         -- Time in seconds between spawns
        spawn_decrease_rate = 0.05, -- Decrease spawn interval by this amount every 10 seconds
        spawn_min_interval = 0.5,   -- Minimum spawn interval
    }
    local obj = setmetatable(props, State)
    return obj
end

return State
