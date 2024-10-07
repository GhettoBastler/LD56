local util = require("util")
local Water = require("water")
local Tile = require("tile")

local Pushable = {
    graphics = {
        pushable = love.graphics.newImage("gfx/pushable.png"),
    },
    audio = {
        push = love.audio.newSource("sfx/push.wav", "static"),
        splash = love.audio.newSource("sfx/splash.wav", "static"),
    }
}

function Pushable:new(x, y, grid)
    local n = {}
    setmetatable(n, self)
    self.__index = self
    n.position = {
        x = x,
        y = y,
    }
    n.grid = grid
    n.state = "idle"
    n.move_fraction = 0
    n.draw_on_top = false
    return n
end

function Pushable:add(x, y, grid)
    local new_pushable = Pushable:new(x, y, grid)
    grid.objects[x+1][y+1] = new_pushable
end

function Pushable:push(direction)
    local did_push = false
    if self.state == "idle" then
        local target_x, target_y = self.position.x, self.position.y
        if direction == 0 then -- left
            target_x = target_x - 1
        elseif direction == 1 then -- right
            target_x = target_x + 1
        elseif direction == 2 then -- up
            target_y = target_y - 1
        else -- down
            target_y = target_y + 1
        end

        if util.point_in_rect(target_x, target_y, 0, 0, self.grid.SIZE, self.grid.SIZE) then
            local object_at_target = self.grid.objects[target_x+1][target_y+1]
            if not object_at_target
               or getmetatable(object_at_target) == Water then
                -- space is free or water, move
                self.state = "moving"
                self.new_position = {x=target_x, y=target_y}
                self.audio.push:play()
                did_push = true
            end
        end
    end
    return did_push
end

function Pushable:update()
    self.draw_on_top = false
    if self.state == "moving" then
        self.draw_on_top = true
        if self.move_fraction > 1 then
            self.move_fraction = 0
            self.state = "idle"
            -- update grid
            self.grid.objects[self.position.x+1][self.position.y+1] = nil
            self.position = self.new_position
            local old_object = self.grid.objects[self.position.x+1][self.position.y+1]
            if old_object and getmetatable(old_object) == Water then
                -- remove self from grid
                self.grid.objects[self.position.x+1][self.position.y+1] = nil
                -- set tile to sunken
                Tile:add(self.position.x, self.position.y, "sunken", self.grid)
                self.audio.splash:play()
            else
                self.grid.objects[self.position.x+1][self.position.y+1] = self
                self.new_position = nil
            end
        else
            self.move_fraction = self.move_fraction + 0.05
        end
    end
end

function Pushable:draw()
    local sprite = self.graphics.pushable
    local x, y = self.position.x * self.grid.TILE_SIZE,
                 self.position.y * self.grid.TILE_SIZE
    if self.state == "moving" then
        x = (self.move_fraction * self.new_position.x + (1 - self.move_fraction) * self.position.x) * self.grid.TILE_SIZE
        y = (self.move_fraction * self.new_position.y + (1 - self.move_fraction) * self.position.y) * self.grid.TILE_SIZE
        x = x + love.math.random() * 4 - 2
        y = y + love.math.random() * 4 - 2
    end
    love.graphics.draw(sprite, x, y)
end

return Pushable
