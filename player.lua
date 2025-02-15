local Player = {}
Player.__index = Player

function Player:new()
    local props = {
        x = 400,
        y = 300,
        radius = 15,
        speed = 200,
        color = { 1, 1, 1 },
        is_dashing = false,
        dash_timer = 0,
        dash_cooldown_timer = 0,
        dx = 0,
        dy = 0
    }

    local obj = setmetatable(props, Player)

    return obj
end

return Player
