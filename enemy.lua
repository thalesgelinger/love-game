--- @class EnemyProps
--- @field x number X position
--- @field y number Y position

--- @class Enemy: EnemyProps
local Enemy = {}
Enemy.__index = Enemy

---@param x number X position
---@param y number Y position
---@return Enemy
function Enemy:new(x, y)
    local props = {
        x = x,
        y = y,
        radius = 15,
        color = { 1, 0, 0 }
    }
    local obj = setmetatable(props, Enemy)
    return obj
end

return Enemy
