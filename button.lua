local util = require "util"

local Button = {}

-- Rectangular buttons for menu items

function Button:new(text, x, y, w, h, callback, colors_pressed, colors_released, font)
    local b = {}
    setmetatable(b, self)
    self.__index = self
    b.text = text
    b.x = x
    b.y = y
    b.w = w
    b.h = h
    b.callback = callback
    b.state = 0 -- 0: idle, 1: hovered, 2: pressed
    b.colors_pressed = {{0, 0, 0}, {1, 1, 1}}
    if colors_pressed then
        b.colors_pressed = {
            util.hex_to_col(colors_pressed[1]),
            util.hex_to_col(colors_pressed[2]),
        }
    end
    b.colors_released = {{1, 1, 1}, {0, 0, 0}}
    if colors_released then
        b.colors_released = {
            util.hex_to_col(colors_released[1]),
            util.hex_to_col(colors_released[2]),
        }
    end
    b.font = font or love.graphics.newFont(18)
    return b
end

function Button:init()
    self.state = 0
end

function Button:update()
    local mouse_x, mouse_y = love.mouse.getPosition()
    -- Idle
    if self.state == 0 then
        if util.point_in_rect(mouse_x, mouse_y, self.x, self.y, self.w, self.h) then
            if #love.touch.getTouches() > 0 then
                -- This is a touch, go directly to pressed
                self.state = 2
            elseif not love.mouse.isDown(1) then
               -- Button is hovered
               self.state = 1
            end
        end
    -- Hovered
    elseif self.state == 1 then
        if not util.point_in_rect(mouse_x, mouse_y, self.x, self.y, self.w, self.h) then
            -- Mouse exited
            self.state = 0
        elseif love.mouse.isDown(1) then
            -- Button pressed
            self.state = 2
        end
    -- Pressed
    elseif self.state == 2 then
        if not util.point_in_rect(mouse_x, mouse_y, self.x, self.y, self.w, self.h) then
            -- Mouse exited
            self.state = 0
        elseif not love.mouse.isDown(1) then
            -- Button released
            self.state = 3
        end
    elseif self.state == 3 then
        -- Triggering
        if self.callback then
            self.callback()
        end
        self.state = 0
    end
end

function Button:draw()
    local text_color, bg_color = unpack(self.colors_released)
    if self.state == 2 then
        -- Pressed
        text_color, bg_color = unpack(self.colors_pressed)
    end
    love.graphics.setColor(unpack(bg_color))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 20, 20)
    love.graphics.setFont(self.font)
    love.graphics.setColor(unpack(text_color))
    util.draw_centered_text(self.x, self.y, self.w, 0.7*self.h, self.text)
end

return Button
