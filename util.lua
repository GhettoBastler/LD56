local util = {}

function util.elastic(t)
    -- https://easings.net/#easeOutElastic
    local c4 = (2 * math.pi) / 3;
    if x == 0 then
        return 0
    elseif x == 1 then
        return 1
    else
        return 2^(-10*t)*math.sin((10*t - 0.75)*c4)+1
    end
end

function util.normalize_segment(raw_pt_a, raw_pt_b)
    local pt_a = math.min(raw_pt_a, raw_pt_b)
    local pt_b = math.max(raw_pt_a, raw_pt_b)
    return {pt_a, pt_b}
end

function util.draw_centered_text(rectX, rectY, rectWidth, rectHeight, text)
    -- from : https://www.love2d.org/wiki/love.graphics.print
    local font       = love.graphics.getFont()
    local textWidth  = font:getWidth(text)
    local textHeight = font:getHeight()
    love.graphics.print(text, math.floor(rectX+rectWidth/2), math.floor(rectY+5+rectHeight/2), 0, 1, 1, math.floor(textWidth/2), math.floor(textHeight/2))
end

function util.val_in_table(val, table)
    for _, v in pairs(table) do
        if v == val then
            return true
        end
    end
end

function util.segment_in_table(segment, table)
    local a1, b1, a2, b2
    for _, s in pairs(table) do
        a1, b1 = unpack(s)
        a2, b2 = unpack(segment)
        if (a1 == a2) and (b1 == b2) then
            return true
        end
    end
end


return util
