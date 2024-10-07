local util = require("util")

local toolbar = {
    buttons = {
        {0, 0, 50, 50, love.graphics.newImage("gfx/arrow_icon.png")},
        {65, 0, 50, 50, love.graphics.newImage("gfx/one_use_icon.png")},
    }
}

function toolbar:init()
    self.selected = 1
end

function toolbar:update(mouse_offset_x, mouse_offset_y)
    local mouse_x, mouse_y = love.mouse.getPosition()
    mouse_x = mouse_x - mouse_offset_x
    mouse_y = mouse_y - mouse_offset_y

    self.hovered = nil
    for idx, button in pairs(self.buttons) do
        local rect_x, rect_y, rect_w, rect_h = unpack(button)
        if util.point_in_rect(mouse_x, mouse_y, rect_x, rect_y, rect_w, rect_h) then
            self.hovered = idx
            break
        end
    end
    if self.hovered then
        if love.mouse.isDown(1) then
            self.selected = self.hovered
        end
    end
end

function toolbar:draw()
    love.graphics.clear()
    for idx, button in pairs(self.buttons) do
        love.graphics.setColor(1, 1, 1)
        local rect_x, rect_y, rect_w, rect_h, icon = unpack(button)
        love.graphics.draw(icon, rect_x, rect_y)
        love.graphics.setLineWidth(1)
        local color = "#ffffff"
        if self.selected == idx then
            love.graphics.setLineWidth(4)
            color = "#ff0000"
        end
        love.graphics.setColor(util.hex_to_col(color))
        love.graphics.rectangle("line", rect_x, rect_y, rect_w, rect_h)
    end
end

return toolbar
