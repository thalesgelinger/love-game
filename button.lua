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

return Button
