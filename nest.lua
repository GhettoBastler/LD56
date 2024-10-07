local Beetle = require("beetle")

local Nest = {
    graphics = {
        nest = love.graphics.newImage("gfx/nest.png"),
        arrows = {
            up = love.graphics.newImage("gfx/nest_arrow_up.png"),
            down = love.graphics.newImage("gfx/nest_arrow_down.png"),
            left = love.graphics.newImage("gfx/nest_arrow_left.png"),
            right = love.graphics.newImage("gfx/nest_arrow_right.png"),
        },
    },
}

function Nest:new(x, y, dir, number, grid)
    local n = {}
    setmetatable(n, self)
    self.__index = self
    n.position = {
        x = x,
        y = y,
    }
    n.direction = dir
    n.remaining = number
    n.grid = grid

    return n
end

function Nest:add(x, y, dir, number, grid)
    local new_nest = Nest:new(x, y, dir, number, grid)
    grid.objects[x+1][y+1] = new_nest
end

function Nest:spawn()
    -- tries to spawn a new beetle if there are remaining
    if self.remaining > 0 then
        self.remaining = self.remaining - 1
        return Beetle:new(self.position.x, self.position.y, self.direction, self.grid)
    end
end

function Nest:draw()
    love.graphics.setColor(1, 1, 1)
    local x, y = self.position.x * self.grid.TILE_SIZE,
                 self.position.y * self.grid.TILE_SIZE
    love.graphics.draw(self.graphics.nest, x, y)
    local arrow_sprite
    if self.direction == 0 then
        arrow_sprite = self.graphics.arrows.left
    elseif self.direction == 1 then
        arrow_sprite = self.graphics.arrows.right
    elseif self.direction == 2 then
        arrow_sprite = self.graphics.arrows.up
    else
        arrow_sprite = self.graphics.arrows.down
    end
    love.graphics.draw(arrow_sprite, x, y)
end

return Nest
