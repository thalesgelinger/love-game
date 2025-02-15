--- @class ButtonProps
--- @field x number
--- @field y number
--- @field width number
--- @field height number
--- @field text string

--- @class Button : ButtonProps
local Button = {}
Button.__index = Button



---@param props ButtonProps
---@return Button
function Button:new(props)
    --- @type Button
    local obj = setmetatable(props, Button)

    return obj
end

function Button:clicked(x, y)
    return x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height
end

function Button:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.text, self.x, self.y + self.height / 2 - 10,
        self.width, "center")
end

return Button
