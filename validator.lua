local util = require("util")

local triangle_segments = {
    {1, 4},
    {4, 6},
    {1, 6},
}
local triangle_shifts = 8
local square_segments = {
    {1, 3},
    {3, 5},
    {5, 7},
    {1, 7},
}
local square_shifts = 2
local line_segments = {
    {1, 5},
}
local line_shifts = 4
local octogon_segments = {
    {1, 2},
    {2, 3},
    {3, 4},
    {4, 5},
    {5, 6},
    {6, 7},
    {7, 8},
    {1, 8},
}
local octogon_shifts = 1

local validator = {}

function rotate_segment(segment, steps)
    local pt_a, pt_b = unpack(segment)
    pt_a = ((pt_a + steps - 1) % 8) + 1
    pt_b = ((pt_b + steps - 1) % 8) + 1
    return util.normalize_segment(pt_a, pt_b)
end

function validator:check_figure(segments, figure_segments, n_shifts)
    local found = {}
    local skip
    local curr_segments = {}
    for i=1, #figure_segments do
        table.insert(curr_segments, {})
    end
    for shift=0, n_shifts-1 do
        for i=1, #figure_segments do
            curr_segments[i] = rotate_segment(figure_segments[i], shift)
        end
        skip = false
        for _, s in pairs(curr_segments) do
            if not util.segment_in_table(s, segments) then
                -- one segment of the figure is not here
                skip = true
                break
            end
        end
        if not skip then
            -- all segments were found, adding this to the results
            table.insert(found, {})
            for i, s in pairs(curr_segments) do
                found[#found][i] = {unpack(s)}
            end
        end
    end
    return found
end

function validator:check(segments)
    print(("checking %s segments"):format(#segments))
    -- triangles
    local triangle_found = self:check_figure(segments, triangle_segments, triangle_shifts)
    -- squares
    local square_found = self:check_figure(segments, square_segments, square_shifts)
    -- lines
    local line_found = self:check_figure(segments, line_segments, line_shifts)
    -- octogon
    local octogon_found = self:check_figure(segments, octogon_segments, octogon_shifts)
    -- checking for unused segments
    local unused = {}
    local skip
    for _, s in pairs(segments) do
        skip = false
        -- is this segment used in one of the triangles ?
        for _, t in ipairs(triangle_found) do
            if util.segment_in_table(s, t) then
                -- yes
                skip = true
                break
            end
        end
        if not skip then
            -- is this segment used in one of the squares ?
            for _, t in ipairs(square_found) do
                if util.segment_in_table(s, t) then
                    -- yes
                    skip = true
                    break
                end
            end
        end
        if not skip then
            -- is this segment used in one of the lines ?
            for _, t in ipairs(line_found) do
                if util.segment_in_table(s, t) then
                    -- yes
                    skip = true
                    break
                end
            end
        end
        if not skip then
            -- is this segment used in one of the octogons ?
            for _, t in ipairs(octogon_found) do
                if util.segment_in_table(s, t) then
                    -- yes
                    skip = true
                    break
                end
            end
        end
        if not skip then
            -- if we arrived here, then this segment has not been used
            table.insert(unused, s)
        end
    end
    return {triangle_found, square_found, line_found, octogon_found, unused}
end

return validator
