local Tile = {
    graphics = {
        normal = {
            up = love.graphics.newImage("gfx/arrow_up.png"),
            down = love.graphics.newImage("gfx/arrow_down.png"),
            left = love.graphics.newImage("gfx/arrow_left.png"),
            right = love.graphics.newImage("gfx/arrow_right.png"),
            sunken = love.graphics.newImage("gfx/pushable_sunken.png"),
        },
        one_use = {
            up = love.graphics.newImage("gfx/arrow_up_one_use.png"),
            down = love.graphics.newImage("gfx/arrow_down_one_use.png"),
            left = love.graphics.newImage("gfx/arrow_left_one_use.png"),
            right = love.graphics.newImage("gfx/arrow_right_one_use.png"),
        },
    },
}

function Tile:new(x, y, direction, grid, one_use)
    local n = {}
    setmetatable(n, self)
    self.__index = self
    n.position = {
        x = x,
        y = y,
    }
    n.grid = grid
    n.direction = direction
    n.one_use = one_use
    n.enabled = true
    return n
end

function Tile:reset()
    if self.direction == "sunken" then
        self:remove()
    elseif not self.enabled then
        self.enabled = true
    end
end

function Tile:add(x, y, direction, grid, one_use)
    local new_tile = Tile:new(x, y, direction, grid, one_use)
    grid.tiles[x+1][y+1] = new_tile
end

function Tile:remove()
    self.grid.tiles[self.position.x+1][self.position.y+1] = nil
end

function Tile:disable()
    self.enabled = false
end

function Tile:draw()
    if not self.enabled then
        return
    end
    local x, y = self.position.x * self.grid.TILE_SIZE,
                 self.position.y * self.grid.TILE_SIZE
    love.graphics.draw(self:get_sprite(), x, y)
end

function Tile:get_sprite()
    local sprite_pool = self.graphics.normal
    if self.one_use then
        sprite_pool = self.graphics.one_use
    end
    return sprite_pool[self.direction]
end


return Tile
