local Button = require "button"

local ImageButton = Button:new()
ImageButton.__index=ImageButton

function ImageButton:new(img_released, x, y, callback, img_pressed)
   local b = Button:new("", x, y, img_released:getWidth(), img_released:getHeight(), callback)
   setmetatable(b, self)
   b.img_released = img_released
   b.img_pressed = img_pressed
   return b
end

function ImageButton:draw()
    love.graphics.setColor(1, 1, 1)
    local img = self.img_released
    if self.state == 2 then
        -- Pressed
        img = self.img_pressed
    end
    love.graphics.draw(img, self.x, self.y)
end

return ImageButton
