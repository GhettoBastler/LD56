local ImageButton = require("imagebutton")
local ToggleButton = require("togglebutton")
local util = require("util")
local grid = require("grid")
local end_overlay = require("end_overlay")
local pause_overlay = require("pause_overlay")
local palette = require("palette")
local fonts = require("fonts")
local toolbar = require("toolbar")

local game_scene = {
    GRID_OFFSET = {
        x = 78,
        y = 40,
    },
    SPAWN_DELAY = 10,
    TOOLBAR_OFFSET = {
        x = 100,
        y = 700,
    },
    grid = grid,

    audio = {
        goal = love.audio.newSource("sfx/goal.wav", "static"),
        win = love.audio.newSource("sfx/win.wav", "static"),
    },
    graphics = {
        play = love.graphics.newImage("gfx/play.png"),
        stop = love.graphics.newImage("gfx/stop.png"),
    }
}

function game_scene:reset()
    -- reset beetles
    self.beetles = {}
    -- reset grid
    self.grid:reset()
    -- reset nests
    self.nests = grid:get_nests()
    -- reset goals
    self.goals = grid:get_goals()
end

function game_scene:init(level_string)
    self.level_string = level_string or self.level_string

    -- toolbar
    toolbar:init()
    self.toolbar_canvas = love.graphics.newCanvas(255, 60)

    -- buttons
    self.buttons = {
        ImageButton:new(
            love.graphics.newImage('gfx/pause_released.png'), 700, 0,
            function () self.state = "paused" end,
            love.graphics.newImage('gfx/pause_pressed.png')
        ),
        ToggleButton:new(
            "Play",
            350, 700, 100, 40,
            function (play)
                self:reset()
                self.state = play and "playing" or "setup"
            end,
            "Stop",
            {"#ffffff", "#ffffff"},
            {"#ffffff", "#ffffff"},
            fonts.tiny
        )
    }

    -- canvas
    local grid_canvas_size = 2*self.grid.BORDER_WIDTH + self.grid.SIZE * self.grid.TILE_SIZE
    self.grid_canvas = love.graphics.newCanvas(grid_canvas_size, grid_canvas_size)

    -- grid
    self.grid:init(self.level_string)

    -- beetles
    self.spawn_timer = 0
    self.beetles = {}
    self.nests = grid:get_nests()
    -- goals
    self.goals = grid:get_goals()

    -- game state
    self.beetle_count = 0
    self.target_count = 0
    self.grid.place_one_use = false

    -- initialize counts
    self:update_counts()

    -- self.state = "playing"
    self.state = "setup"
end

function game_scene:update_counts()
    -- update counts
    self.beetle_count = #self.beetles
    for _, nest in pairs(self.nests) do
        self.beetle_count = self.beetle_count + nest.remaining
    end
    self.target_count = 0
    for _, goal in pairs(self.goals) do
        self.target_count = self.target_count + goal.target
    end
end

function game_scene:update()
    if self.state == "setup" then
        -- update tool
        if toolbar.selected == 1 then
            self.grid.place_one_use = false
        elseif toolbar.selected == 2 then
            self.grid.place_one_use = true
        end

        -- ui
        toolbar:update(self.TOOLBAR_OFFSET.x, self.TOOLBAR_OFFSET.y)
        for _, button in pairs(self.buttons) do
            button:update()
        end

        local mouse_x, mouse_y = love.mouse.getPosition()
        self.grid:update(mouse_x - self.GRID_OFFSET.x, mouse_y - self.GRID_OFFSET.y)

    elseif self.state == "playing" then
        -- update counts
        self:update_counts()

        -- check win/lose state
        if self.target_count <= 0 then
            -- no more beetle to get to goal: we win!
            self.state = "won"
            self.audio.win:play()
            print("Win!")
            return
        elseif self.beetle_count < self.target_count then
            -- not enough beetles to reach the goal: we lose
            self.state = "lost"
            print("lose!")
            return
        end

        -- spawn beetles
        if self.spawn_timer <= 0 then
            for _, nest in pairs(self.nests) do
                local new_beetle = nest:spawn()
                if new_beetle then
                    table.insert(self.beetles, new_beetle)
                end
            end
            self.spawn_timer = self.SPAWN_DELAY
        else
            self.spawn_timer = self.spawn_timer - 1
        end

        -- update beetles
        for idx, beetle in pairs(self.beetles) do
            beetle:update()
            if beetle.state == "at_goal" then
                -- remove beetle
                table.remove(self.beetles, idx)
                self.audio.goal:play()
            elseif beetle.state == "dead" then
                -- kill
                table.remove(self.beetles, idx)
            end
        end

        -- update grid
        local mouse_x, mouse_y = love.mouse.getPosition()
        self.grid:update(mouse_x - self.GRID_OFFSET.x, mouse_y - self.GRID_OFFSET.y, true)

        -- ui
        for _, button in pairs(self.buttons) do
            button:update()
        end
    elseif self.state == "paused" then
        pause_overlay:update()
    elseif self.state == "won" or self.state == "lost" then
        end_overlay:update(self.state == "won")
    end
end

function game_scene:draw()
    -- grid ganvas
    love.graphics.setCanvas(self.grid_canvas)
    love.graphics.clear()
    -- draw grid (bottom layer)
    self.grid:draw()
    -- draw beetles
    for _, beetle in pairs(self.beetles) do
        beetle:draw()
    end
    -- draw grid (top layer)
    self.grid:draw(true)
    -- draw canvas on screen
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.grid_canvas, self.GRID_OFFSET.x, self.GRID_OFFSET.y)

    -- ui
    -- love.graphics.setFont(fonts.tiny)
    -- love.graphics.print(self.beetle_count, 670, 700)
    -- love.graphics.print(self.target_count, 670, 720)
    for _, button in pairs(self.buttons) do
        button:draw()
    end
    -- toolbar
    if self.state == "setup" then
        love.graphics.setCanvas(self.toolbar_canvas)
        toolbar:draw()
        love.graphics.setColor(1, 1, 1)
        love.graphics.setCanvas()
        love.graphics.draw(self.toolbar_canvas, self.TOOLBAR_OFFSET.x, self.TOOLBAR_OFFSET.y)
    end

    -- overlays
    if self.state == "paused" then
        pause_overlay:draw()
    elseif self.state == "won" then
        end_overlay:draw(true)
    elseif self.state == "lost" then
        end_overlay:draw()
    end
end

return game_scene
