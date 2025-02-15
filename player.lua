--- @class PlayerProps
--- @field x number
--- @class Player: PlayerProps
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

function Player:attack(key, game_state)
    if key == "k" and not self.is_dashing and self.dash_cooldown_timer <= 0 and not game_state.game_over then
        self.is_dashing = true
        self.dash_timer = game_state.dash_duration
        self.dash_cooldown_timer = game_state.dash_cooldown
    end
end

function Player:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Player:restart()
    self.x = 400
    self.y = 300
    self.is_dashing = false
    self.dash_timer = 0
    self.dash_cooldown_timer = 0
end

return Player
