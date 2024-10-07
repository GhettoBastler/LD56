local util = require "util" 
local Button = require "button"
local fonts = require "fonts"

local ToggleButton = Button:new()
ToggleButton.__index=ToggleButton

function ToggleButton:new(text, x, y, w, h, callback, text_on, colors_on, colors_off, font)
   local b = Button:new(text, x, y, w, h, nil, colors_on, colors_off, font)
   setmetatable(b, self)
   b.toggle_callback = callback
   b.text_on = text_on
   b.on = false
   return b
end

function ToggleButton:init()
    Button.init(self)
    self.on = false
end

function ToggleButton:update()
    Button.update(self)
    if self.state == 3 then
        self.on = not self.on
        self.toggle_callback(self.on)
    end
end

function ToggleButton:draw()
    local text_color, bg_color = unpack(self.colors_released)
    local text = self.text
    if self.on then
        -- On
        text_color, bg_color = unpack(self.colors_pressed)
        text = self.text_on or text
    end
    love.graphics.setColor(unpack(bg_color))
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 20, 20)
    love.graphics.setFont(self.font)
    love.graphics.setColor(unpack(text_color))
    util.draw_centered_text(self.x, self.y, self.w, self.h*0.6, text)
end

return ToggleButton
