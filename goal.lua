local Goal = {
    graphics = {
        open = love.graphics.newImage("gfx/goal_open.png"),
        closed = love.graphics.newImage("gfx/goal_closed.png"),
    },
}

function Goal:new(x, y, target, grid)
    local n = {}
    setmetatable(n, self)
    self.__index = self
    n.position = {
        x = x,
        y = y,
    }
    n.target = target
    n.grid = grid
    n.is_open = true
    return n
end

function Goal:add(x, y, target, grid)
    local new_goal = Goal:new(x, y, target, grid)
    grid.objects[x+1][y+1] = new_goal
end

function Goal:decrement()
    self.target = self.target - 1
    if self.target <= 0 then
        self.is_open = false
    end
end

function Goal:draw()
    local sprite = self.graphics.closed
    if self.is_open then
        sprite = self.graphics.open
    end
    local x, y = self.position.x * self.grid.TILE_SIZE,
                 self.position.y * self.grid.TILE_SIZE
    love.graphics.draw(sprite, x, y)
end

return Goal
