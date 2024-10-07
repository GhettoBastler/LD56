local Water = {
    graphics = {
        water = love.graphics.newImage("gfx/water.png"),
    },
}

function Water:new(x, y, grid)
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

function Water:add(x, y, grid)
    local new_water = Water:new(x, y, grid)
    grid.objects[x+1][y+1] = new_water
end

function Water:draw()
    local x, y = self.position.x * self.grid.TILE_SIZE,
                 self.position.y * self.grid.TILE_SIZE
    love.graphics.draw(self.graphics.water, x, y)
end

return Water
