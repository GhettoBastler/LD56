local util = {}

function util.draw_centered_text(rectX, rectY, rectWidth, rectHeight, text)
    -- from : https://www.love2d.org/wiki/love.graphics.print
    local font       = love.graphics.getFont()
    local textWidth  = font:getWidth(text)
    local textHeight = font:getHeight()
    love.graphics.print(text, math.floor(rectX+rectWidth/2), math.floor(rectY+5+rectHeight/2), 0, 1, 1, math.floor(textWidth/2), math.floor(textHeight/2))
end

function util.hex_to_col(hex)
    local col = {}
    -- strip #
    if string.sub(hex, 1, 1) == "#" then
        hex = string.sub(hex, 2, #hex)
    end
    for idx=1, #hex, 2 do
        table.insert(col, tonumber(string.sub(hex, idx, idx+1), 16)/255)
    end
    return col
end

function util.enter_scene(scene, ...)
    -- override game loop
    love.update = function() scene:update() end
    love.draw = function() scene:draw() end
    -- initialize scene
    scene:init(...)
end

function util.point_in_rect(px, py, x, y, w, h)
    return px >= x and px < x+w and
           py >= y and py < y+h
end

return util
