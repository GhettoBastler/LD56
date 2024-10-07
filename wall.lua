local Wall = {
    graphics = {
        wall = love.graphics.newImage("gfx/wall.png"),
    },
}

function Wall:new(x, y, grid)
    local n = {}
    setmetatable(n, self)
    self.__index = self
    n.position = {
        x = x,
        y = y,
    }
    n.grid = grid
    return n
end

function Wall:add(x, y, grid)
    local new_wall = Wall:new(x, y, grid)
    grid.objects[x+1][y+1] = new_wall
end

-- function Wall:get_sprite()
--     return self.graphics.wall
-- end

function Wall:draw()
    local x, y = self.position.x * self.grid.TILE_SIZE,
                 self.position.y * self.grid.TILE_SIZE
    love.graphics.draw(self.graphics.wall, x, y)
end

return Wall
