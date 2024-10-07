local Nest = require("nest")
local Wall = require("wall")
local Water = require("water")
local Pushable = require("pushable")
local Goal = require("goal")
local palette = require("palette")
local util = require("util")
local Tile = require("tile")

local grid = {
    -- parameters
    SIZE = 10,
    TILE_SIZE = 64,
    BORDER_WIDTH = 2,
    -- gfx
    graphics = {
        grid = love.graphics.newImage("gfx/grid.png"),
        tiles = {
            up = love.graphics.newImage("gfx/arrow_up.png"),
            down = love.graphics.newImage("gfx/arrow_down.png"),
            left = love.graphics.newImage("gfx/arrow_left.png"),
            right = love.graphics.newImage("gfx/arrow_right.png"),
            sunken = love.graphics.newImage("gfx/pushable_sunken.png"),
        },
    },
    -- sfx
    audio = {
        push = love.audio.newSource("sfx/push.wav", "static"),
    }
}

function grid:parse_level_string(level_string)
    local nests, goals, walls, pushables, waters = {}, {}, {}, {}, {}
    local x, y = 0, 0
    local level_string = string.gsub(level_string, " ", "")
    for line in level_string:gmatch("[^\r\n]+") do
        x = 0
        for item in line:gmatch("[^,]+") do
            local key = string.sub(item, 1, 1)
            if key == "N" then
                -- nest
                local direction = tonumber(string.sub(item, 2, 2))
                table.insert(nests, {x, y, direction, 10})
            elseif key == "G" then
                -- goal
                table.insert(goals, {x, y, 10})
            elseif key == "W" then
                -- wall
                table.insert(walls, {x, y})
            elseif key == "P" then
                -- pushable
                table.insert(pushables, {x, y})
            elseif key == "X" then
                -- water
                table.insert(waters, {x, y})
            end
            x = x + 1
        end
        y = y + 1
    end

    for _, nest in pairs(nests) do
        local x, y, dir, number = unpack(nest)
        Nest:add(x, y, dir, number, self)
    end

    for _, wall in pairs(walls) do
        local x, y = unpack(wall)
        Wall:add(x, y, self)
    end

    for _, goal in pairs(goals) do
        local x, y, target = unpack(goal)
        Goal:add(x, y, target, self)
    end

    for _, water in pairs(waters) do
        local x, y = unpack(water)
        Water:add(x, y, self)
    end

    for _, pushable in pairs(pushables) do
        local x, y = unpack(pushable)
        Pushable:add(x, y, self)
    end
end

function grid:reset()
    -- reset objects and tiles
    for col=1, self.SIZE do
        for row=1, self.SIZE do
            self.objects[col][row] = nil
            local tile = self.tiles[col][row]
            if tile then
                tile:reset()
            end
        end
    end
    -- parse level string again
    self:parse_level_string(self.level_string)
end

function grid:init(level_string)
    self.level_string = level_string
    -- initialize layers
    self.objects = {}
    self.tiles = {}
    for col=1, self.SIZE do
        local col_tile, col_object = {}, {}
        for row=1, self.SIZE do
            table.insert(col_tile, nil)
            table.insert(col_object, nil)
        end
        table.insert(self.tiles, col_tile)
        table.insert(self.objects, col_object)
    end

    -- parse level string
    self:parse_level_string(self.level_string)

    -- cursor
    self.coord_hovered = nil
    self.placing = false
end

function grid:get_nests()
    local nests = {}
    for i=1, self.SIZE do
        for j=1, self.SIZE do
            if getmetatable(self.objects[i][j]) == Nest then
                table.insert(nests, self.objects[i][j])
            end
        end
    end
    return nests
end

function grid:get_goals()
    local goals = {}
    for i=1, self.SIZE do
        for j=1, self.SIZE do
            if getmetatable(self.objects[i][j]) == Goal then
                table.insert(goals, self.objects[i][j])
            end
        end
    end
    return goals
end

function grid:update(mouse_x, mouse_y, locked)
    -- update objects
    for i=1, self.SIZE do
        for j=1, self.SIZE do
            local object = self.objects[i][j]
            if object and object.update then
                object:update()
            end
        end
    end

    if locked then
        self.coord_hovered = nil
        self.placing = false
        return
    end
    -- get grid coordinates
    local grid_x, grid_y = math.floor(mouse_x / self.TILE_SIZE),
                           math.floor(mouse_y / self.TILE_SIZE)
    -- if we are not currently placing a tile, update the hovered tile
    if not self.placing then
        if util.point_in_rect(grid_x, grid_y, 0, 0, self.SIZE, self.SIZE)
        and self:can_place(grid_x, grid_y) then
            self.coord_hovered = {
                x = grid_x,
                y = grid_y,
            }
        else
            self.coord_hovered = nil
        end

        -- check click
        if self.coord_hovered and love.mouse.isDown(1) then
            self.placing = true
            self.new_tile = nil
        end
    else
        -- currently placing a tile
        -- select which tile to place
        self.new_tile = self.new_tile or {direction="up"}
        self.new_tile.one_use = self.place_one_use
        local offset_x, offset_y = grid_x - self.coord_hovered.x,
                                   grid_y - self.coord_hovered.y

        if offset_x < 0 and offset_y == 0 then -- left
            self.new_tile.direction = "left"
        elseif offset_x > 0 and offset_y == 0 then -- right
            self.new_tile.direction = "right"
        elseif offset_y < 0 and offset_x == 0 then -- up
            self.new_tile.direction = "up"
        elseif offset_y > 0 and offset_x == 0 then -- down
            self.new_tile.direction = "down"
        elseif offset_y == 0 and offset_x == 0 then -- center (remove)
            self.new_tile = nil
        end

        if not love.mouse.isDown(1) then
            -- place the new tile
            self.placing = false
            if self.new_tile then
                Tile:add(self.coord_hovered.x, self.coord_hovered.y, self.new_tile.direction, self, self.new_tile.one_use)
            else
                local curr_tile = self.tiles[self.coord_hovered.x+1][self.coord_hovered.y+1]
                if curr_tile then
                    curr_tile:remove()
                end
            end
        end
    end
end

function grid:try_moving(x, y, direction)
    local target_x, target_y = x, y
    local result = "moved"
    if direction == 0 then -- left
        target_x = target_x - 1
    elseif direction == 1 then -- right
        target_x = target_x + 1
    elseif direction == 2 then -- up
        target_y = target_y - 1
    else -- down
        target_y = target_y + 1
    end

    -- borders
    if target_x < 0 or target_x >= self.SIZE
    or target_y < 0 or target_y >= self.SIZE then
        return false
    end
    -- objects
    local object = self.objects[target_x+1][target_y+1]
    if object then
        -- wall
        if getmetatable(object) == Wall then
            return false
        -- pushable
        elseif getmetatable(object) == Pushable then
            if object.state ~= "sunken" then
                if object:push(direction) then
                    return "pushed"
                end
                return false
            end
        end
    end

    return "moved"
end

function grid:get_tile(x, y)
    return self.tiles[x+1][y+1]
end

function grid:get_object(x, y)
    return self.objects[x+1][y+1]
end

function grid:can_place(x, y)
    if self.objects[x+1][y+1] then
        return false
    else
        local tile = self.tiles[x+1][y+1]
        if tile and tile.direction == "sunken" then
            return false
        end
    end
    return true
end

function grid:draw(top)
    if not top then
        -- draw grid
        love.graphics.setBackgroundColor(palette.main.DARK_BROWN)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.graphics.grid)

        -- draw placed tiles
        love.graphics.setColor(1, 1, 1)
        for i, col in pairs(self.tiles) do
            for j, tile in pairs(col) do
                -- check that the player is not placing a new tile here
                if not (
                    self.placing
                    and self.coord_hovered.x == i-1
                    and self.coord_hovered.y == j-1) then
                    tile:draw()
                end
            end
        end

        -- draw hovered tile
        love.graphics.setColor(1, 1, 1)
        if self.coord_hovered then
            local rect_x, rect_y = self.coord_hovered.x * self.TILE_SIZE,
                                   self.coord_hovered.y * self.TILE_SIZE,
            love.graphics.setColor(palette.main.LIGHT_GREEN)
            love.graphics.setLineWidth(4)
            love.graphics.rectangle("line", 2+rect_x, 2+rect_y, self.TILE_SIZE, self.TILE_SIZE)
            -- placing a tile ?
            if self.placing then
                love.graphics.setColor(1, 1, 1, 0.5)
                local sprite
                if self.new_tile then
                    if self.new_tile.one_use then
                        sprite = Tile.graphics.one_use[self.new_tile.direction]
                    else
                        sprite = Tile.graphics.normal[self.new_tile.direction]
                    end
                else
                    local curr_tile = self.tiles[self.coord_hovered.x+1][self.coord_hovered.y+1]
                    if curr_tile then
                        sprite = curr_tile:get_sprite()
                    end
                end
                if sprite then
                    love.graphics.draw(sprite, rect_x, rect_y)
                end
            end
        end
    end

    -- draw objects
    love.graphics.setColor(1, 1, 1)
    for i, col in pairs(self.objects) do
        for j, object in pairs(col) do
            if (object.draw_on_top and top)
            or (not object.draw_on_top and not top) then
                object:draw()
            end
        end
    end
end

return grid
