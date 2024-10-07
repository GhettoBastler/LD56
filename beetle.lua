local util = require("util")
local Goal = require("goal")
local Water = require("water")
local Pushable = require("pushable")

local Beetle = {
    SPEED = 0.05,
    graphics = {
        beetle_up = love.graphics.newImage("gfx/beetle_up.png"),
        beetle_down = love.graphics.newImage("gfx/beetle_down.png"),
        beetle_left = love.graphics.newImage("gfx/beetle_left.png"),
        beetle_right = love.graphics.newImage("gfx/beetle_right.png"),
    },
    audio = {
        splash = love.audio.newSource("sfx/splash.wav", "static")
    },
}

function Beetle:new(x, y, dir, grid)
    local b = {}
    setmetatable(b, self)
    self.__index = self

    b.internal_position = 0
    b.position = {
        x = x,
        y = y,
    }
    b.direction = dir
    b.grid = grid

    b.state = "moving"
    b.pause_timer = 0

    return b
end

function Beetle:update()
    -- check if crushed
    local object_here = self.grid.objects[self.position.x+1][self.position.y+1]
    if object_here then
        if getmetatable(object_here) == Pushable then
            if object_here.state ~= "sunken" then
                -- crushed
                print("crushed")
                self.state = "dead"
                return
            end
        end
    end

    if self.state == "moving" then
        self.internal_position = self.internal_position + self.SPEED
        if self.internal_position >= 0.5 then
            -- check tile
            local result = self.grid:try_moving(self.position.x, self.position.y, self.direction)
            if result then
                if result == "pushed" then
                    -- wait after pushing
                    self.state = "paused"
                    self.pause_timer = 15
                    self.internal_position = 0.25
                    return
                else
                    -- move to the space
                    self:step()
                end
            else
                -- rebound
                self:rebound()
            end
        elseif self.internal_position > 0 then
            -- tile/object effect
            local current_object = self.grid:get_object(self.position.x, self.position.y)
            if current_object then
                -- Goal
                if getmetatable(current_object) == Goal then
                    if current_object.is_open then
                        -- enter goal
                        self.state = "at_goal"
                        current_object:decrement()
                        return
                    end
                end
                -- Water
                if getmetatable(current_object) == Water then
                    -- drowned
                    self.audio.splash:play()
                    self.state = "dead"
                    return
                end
            else
                -- check tile
                local current_tile = self.grid:get_tile(self.position.x, self.position.y)
                if current_tile and current_tile.enabled then
                    if current_tile.direction == "left" then
                        self.direction = 0
                    elseif current_tile.direction == "right" then
                        self.direction = 1
                    elseif current_tile.direction == "up" then
                        self.direction = 2
                    elseif current_tile.direction == "down" then
                        self.direction = 3
                    end
                    if current_tile.one_use then
                        current_tile:disable()
                        -- current_tile:remove()
                    end
                end
            end
        end
    elseif self.state == "paused" then
        if self.pause_timer <= 0 then
            self.state = "moving"
        else
            self.pause_timer = self.pause_timer - 1
        end
    end
end

function Beetle:draw()
    local x, y = (0.5 + self.position.x) * self.grid.TILE_SIZE,
                 (0.5 + self.position.y) * self.grid.TILE_SIZE
    local sprite
    if self.direction == 0 then -- left
        x = x - self.internal_position * self.grid.TILE_SIZE
        sprite = self.graphics.beetle_left
    elseif self.direction == 1 then -- right
        x = x + self.internal_position * self.grid.TILE_SIZE
        sprite = self.graphics.beetle_right
    elseif self.direction == 2 then -- up
        y = y - self.internal_position * self.grid.TILE_SIZE
        sprite = self.graphics.beetle_up
    elseif self.direction == 3 then -- down
        y = y + self.internal_position * self.grid.TILE_SIZE
        sprite = self.graphics.beetle_down
    end

    love.graphics.setColor(util.hex_to_col("#ffffff"))
    love.graphics.draw(sprite, x-21, y-20)
end

function Beetle:step()
    if self.direction == 0 then -- left
        self.position.x = self.position.x - 1
    elseif self.direction == 1 then -- right
        self.position.x = self.position.x + 1
    elseif self.direction == 2 then -- up
        self.position.y = self.position.y - 1
    else -- down
        self.position.y = self.position.y + 1
    end
    self.internal_position = -0.5
end

function Beetle:rebound()
    if self.direction == 0 then -- left
        self.direction = 1
    elseif self.direction == 1 then -- right
        self.direction = 0
    elseif self.direction == 2 then -- up
        self.direction = 3
    else --down
        self.direction = 2
    end
    self.internal_position = -0.5
end

return Beetle
