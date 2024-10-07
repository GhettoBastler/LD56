local util = require("util")
local validator = require("validator")
local palette = require("palette")
local demon = require("demon")
local Button = require("button")
local ImageButton = require("imagebutton")
local fonts = require("fonts")

local ORDER_ENTER_LENGTH = 15
local ORDER_EXIT_LENGTH = 15

local CIRCLE_CENTER = {400, 330}
local CIRCLE_RADIUS = 180
local HOVER_RADIUS = 30
local MAX_TIMER = 60
local INVALID_DELAY = 30

local game_scene = {
    hovered = nil,
    last_point = nil,
    segments = {},
    points = {},
    goal_idx = 1,
    result = nil,
    score = 0,
    match = false,
    invalid_timer = 0,
    camera_shake = 0,
    free_mode = false,
    paused = false,
    unused = {},
    timer = 0,
    order_state = 0, -- 0 absent, 1 entering, 2 present, 3 exiting
    order_anim_timer = 0
}

local GOALS = {
    -- {4, 5, 6, true}, -- impossible goal for testing
    -- one symbol
    {1, 0, 0, false},
    {0, 1, 0, false},
    {0, 0, 1, false},
    {0, 0, 0, true},
    -- two symbols
    {2, 0, 0, false},
    {1, 1, 0, false},
    {1, 0, 1, false},
    {0, 1, 1, false},
    -- kinda hard
    {2, 0, 1, false},
    {2, 1, 0, false},
    {2, 1, 1, false},
    -- one symbol winged
    {1, 0, 0, true},
    {0, 1, 0, true},
    {0, 0, 1, true},
    -- two symbol winged
    {1, 0, 1, true},
    {2, 0, 0, true},
    -- more symbol winged
    {2, 0, 1, true},
    {2, 1, 0, true},
    {2, 1, 1, true},
    {3, 1, 0, true},
    -- hard
    {1, 2, 1, true},
    {1, 2, 2, true},
    {3, 2, 2, true},
    {3, 0, 0, false},
    {0, 2, 0, true},
    {0, 2, 0, true},
    {4, 0, 0, false},
    {4, 1, 0, false},
    {4, 1, 0, true},
    {3, 1, 1, false},
    {8, 2, 1, true},
}

local graphics = {
    small_tick = love.graphics.newImage("gfx/small_tick.png"),
    tick = love.graphics.newImage("gfx/tick_mark.png"),
    cross = love.graphics.newImage("gfx/cross_mark.png"),
    order_bg = love.graphics.newImage("gfx/order_bg.png"),
    order_arm = love.graphics.newImage("gfx/order_arm.png"),
    order_legs = love.graphics.newImage("gfx/order_legs.png"),
    order_tail = love.graphics.newImage("gfx/order_tail.png"),
    order_wing = love.graphics.newImage("gfx/order_wing.png"),
    order_circle_arm = love.graphics.newImage("gfx/order_circle_arm.png"),
    order_circle_legs = love.graphics.newImage("gfx/order_circle_legs.png"),
    order_circle_tail = love.graphics.newImage("gfx/order_circle_tail.png"),
    order_circle_wing = love.graphics.newImage("gfx/order_circle_wing.png"),
}

local audio = {
    draw = love.audio.newSource("sfx/draw.wav", "static"),
    invalid = love.audio.newSource("sfx/invalid_circle.wav", "static"),
    spawn = love.audio.newSource("sfx/spawn.wav", "static"),
    spawn_valid = love.audio.newSource("sfx/spawn_valid.wav", "static"),
    spawn_invalid = love.audio.newSource("sfx/spawn_invalid.wav", "static"),
    paper = love.audio.newSource("sfx/paper.wav", "static"),
}

function game_scene.pause_game()
    print("PAUSE")
    game_scene.paused = true
end

function game_scene.unpause_game()
    print("UNPAUSED")
    game_scene.paused = false
end

function exit()
    scenes.title_scene:enter()
end

function game_scene.skip_order()
    if audio.paper:isPlaying() then
        audio.paper:stop()
    end
    audio.paper:play()
    game_scene.order_exit(game_scene)
    game_scene.state = 0
    game_scene.set_new_goal(game_scene)
end

function game_scene.return_to_title()
    scenes.title_scene:enter()
end

function is_close(pos, point)
    return math.sqrt((pos[1]-point[1])^2 + (pos[2]-point[2])^2) < HOVER_RADIUS
end

local pause_screen = {
    buttons = {
        Button:new("Continue", 200, 300, 400, 80, game_scene.unpause_game, button_colors.pressed, button_colors.released, fonts.small),
        Button:new("Return to title", 200, 400, 400, 80, game_scene.return_to_title, button_colors.pressed, button_colors.released, fonts.small)
    }
}

function draw_pause_screen()
    -- overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    love.graphics.setColor(palette[8])
    love.graphics.setFont(fonts.big)
    util.draw_centered_text(0, 80, 800, 100, "Paused")
    for _, b in pairs(pause_screen.buttons) do
        b:draw()
    end
end


local pause_button = ImageButton:new(
    love.graphics.newImage('gfx/pause_released.png'), 700, 0,
    game_scene.pause_game,
    love.graphics.newImage('gfx/pause_pressed.png')
)

function game_scene:enter(free_mode)
    -- start music if is not on
    if music_on and not music:isPlaying() then
        music:play()
    end

    self.paused = false
    self.free_mode = free_mode

    -- load assets. Why here ? idk
    self.background_img = love.graphics.newImage("gfx/background.png")

    -- reset score and segments
    self.score = 0
    self.segments = {}
    self.last_point = nil
    self.invalid_timer = 0
    self.result = nil
    self.match = false
    self.unused = {}

    -- don't show order yet
    self.order_state = 0
    self:order_enter()

    -- button
    self.buttons = {}
    if not self.free_mode then
        table.insert(self.buttons, Button:new("Skip", 50, 250, 100, 50, self.skip_order, button_colors.pressed, button_colors.released, fonts.tiny))
    end

    -- first goal
    self.goal_idx = love.math.random(4)

    -- create points
    points = {}
    local angle
    for i=0, 8 do
        angle = i*math.pi/4
        self.points[i] = {}
        self.points[i][1] = CIRCLE_CENTER[1] + CIRCLE_RADIUS*math.cos(angle)
        self.points[i][2] = CIRCLE_CENTER[2] + CIRCLE_RADIUS*math.sin(angle)
    end

    -- game state
    self.state = 0

    -- start timer
    if not self.free_mode then
        -- self.start_time = love.timer.getTime()
        self.timer = MAX_TIMER
    end

    -- game loop
    love.update = self.update
    love.draw = self.draw
end

function game_scene:update_order()
    -- absent
    if self.order_state == 0 then
        self.order_anim_timer = 0
    -- entering
    elseif self.order_state == 1 then
        if self.order_anim_timer > 0 then
            self.order_anim_timer = self.order_anim_timer - 1
        else
            self.order_state = 2
            self.order_anim_timer = 0
        end
    -- present
    elseif self.order_state == 2 then
        self.order_anim_timer = 0
    -- exiting
    elseif self.order_state == 3 then
        if self.order_anim_timer > 0 then
            self.order_anim_timer = self.order_anim_timer - 1
        else
            self.order_state = 0
            self.order_anim_timer = 0
        end
    end
end

function game_scene:order_enter()
    self.order_anim_timer = ORDER_ENTER_LENGTH
    self.order_state = 1
end

function game_scene:order_exit()
    self.order_anim_timer = ORDER_EXIT_LENGTH
    self.order_state = 3
end

function game_scene.update_hovered()
    for i, p in ipairs(game_scene.points) do
        if is_close({love.mouse.getPosition()}, p) then
            game_scene.hovered = i
            return
        end
    end
    game_scene.hovered = nil
end

function game_scene.update()
    -- pause
    if game_scene.paused then
        for _, b in pairs(pause_screen.buttons) do
            b:update()
        end
        return
    end
    -- pause button
    pause_button:update()

    -- other buttons
    if game_scene.state <= 1 then
        for _, b in pairs(game_scene.buttons) do
            b:update()
        end
    end

    -- order animation
    game_scene.update_order(game_scene)

    -- not drawing a line
    if game_scene.state == 0 then
        -- clear result
        game_scene.result = nil
        -- if just made an invalid circle, show it for a bit
        if game_scene.invalid_timer > 1 then
            game_scene.invalid_timer = game_scene.invalid_timer - 1
        else
            game_scene.invalid_timer = 0
            -- clear current segments
            if #game_scene.segments > 0 then
                game_scene.segments = {}
            end
        end
        -- clear unused segments if any
        if #game_scene.unused > 0 then
            game_scene.unused = {}
        end
        -- check if the mouse is hovering a point
        game_scene.update_hovered()

        -- clicking on a hovered point
        if game_scene.hovered and love.mouse.isDown(1) then
            -- if we're showing the previous invalid circle, reset
            if game_scene.invalid_timer > 0 then
                game_scene.invalid_timer = 0
                if #game_scene.segments > 0 then
                    game_scene.segments = {}
                end
            end
            print("Starting line at point "..game_scene.hovered)
            game_scene.last_point = game_scene.hovered
            game_scene.state = 1
        end
    -- drawing a line
    elseif game_scene.state == 1 then
        -- stop drawing if the mouse is released
        if not love.mouse.isDown(1) then
            if #game_scene.segments > 0 then
                -- a candidate circle has been drawn
                -- checking
                game_scene.state = 2
            else
                -- no line has been drawn
                game_scene.state = 0
            end
        else
            -- check if the mouse is hovering a new point
            game_scene.update_hovered()
            if game_scene.hovered then
                if game_scene.check_new_point(game_scene.hovered) then
                    -- playing draw sound
                    audio.draw:setPitch(0.8+0.4*love.math.random())
                    audio.draw:play()
                    print("adding a new segment")
                    table.insert(game_scene.segments, util.normalize_segment(game_scene.last_point, game_scene.hovered))
                    game_scene.last_point = game_scene.hovered
                    -- calling validator
                    local valid = validator:check(game_scene.segments)
                    game_scene.result = {
                        #valid[1], -- arms
                        #valid[2], -- pairs of legs
                        #valid[3], -- tails
                        #valid[4] > 0, -- winged
                    }
                    game_scene.unused = valid[5]
                end
            end
            game_scene.hovered = nil
        end
    -- checking if the circle is valid
    elseif game_scene.state == 2 then
        local n_unused = #game_scene.unused
        if n_unused > 0 then
            print(("Invalid circle (%s unused)"):format(n_unused))
            game_scene.invalid_timer = INVALID_DELAY
            game_scene.state = 0
            game_scene.camera_shake = 5
            -- playing invalid sound
            audio.invalid:play()
        else
            print("Valid circle")
            demon:generate(game_scene.result)
            -- -- playing sound
            game_scene.state = 3
        end
    -- checking if monster corresponds to order
    elseif game_scene.state == 3 then
        if not game_scene.free_mode then
            if game_scene:check_goal() then
                -- add point
                game_scene.score = game_scene.score + 1
                game_scene.match = true
                print("MATCH!")
                audio.spawn_valid:play()
                -- add some time
                game_scene.timer = math.min(MAX_TIMER, game_scene.timer + 5)
            else
                game_scene.match = false
                print("doesn\'t match order")
                game_scene.camera_shake = 10
                audio.spawn_invalid:play()
            end
        else
            audio.spawn:play()
        end
        game_scene.state = 4
    -- wait for reset
    elseif game_scene.state == 4 then
        if love.mouse.isDown(1) then
            if game_scene.match then
                game_scene.order_exit(game_scene)
            end
            demon:exit()
            game_scene.state = 5
        end
    elseif game_scene.state == 5 then
        print(("Score is %s. Waiting to restart"):format(game_scene.score))
        if demon.state == 0 then
            -- change goal
            if game_scene.match then
                game_scene:set_new_goal()
                game_scene.order_enter(game_scene)
            end
            -- go back
            game_scene.state = 0
        end
    end
    -- camera shake
    if game_scene.camera_shake > 0 then
        game_scene.camera_shake = game_scene.camera_shake - 1
    else
        game_scene.camera_shake = 0
    end
    -- timer
    if not game_scene.free_mode then
        -- don't advance timer when game is paused
        if not game_scene.paused then
            game_scene.timer = game_scene.timer - 1/60
        end
        if game_scene.state < 4 then
            if game_scene.timer <= 0 then
                scenes.results_scene:enter(game_scene.score)
                print("TIME\'S UP")
            end
        end
    end
    -- demon animation
    demon:update()
end

function game_scene:check_goal()
    local goal = GOALS[self.goal_idx]
    -- arms, legs and tails
    for i=1, 3 do
        if goal[i] > 0 and goal[i] ~= self.result[i] then
            return false
        end
    end
    -- winged
    if goal[4] and not self.result[4] then
        return false
    end
    -- for i, v in ipairs(self.result) do
    --     if goal[i] ~= v then
    --         return false
    --     end
    -- end
    return true
end

function game_scene:set_new_goal()
    local cap = 4
    if self.score <= 3 then
        cap = 4
    elseif self.score <= 5 then
        cap = 8
    elseif self.score <= 8 then
        cap = 11
    elseif self.score <= 10 then
        cap = 16
    elseif self.score <= 16 then
        cap = 20
    else
        cap = #GOALS
    end

    local new_goal_idx = self.goal_idx
    while new_goal_idx == self.goal_idx do
        new_goal_idx = love.math.random(cap)
    end
    game_scene:order_enter()
    self.goal_idx = new_goal_idx
end

function game_scene.check_new_point(new_point)
    if game_scene.last_point ~= new_point then
        local pt_a, pt_b = unpack(util.normalize_segment(game_scene.last_point, new_point))
        local s_a, s_b
        for _, s in ipairs(game_scene.segments) do
            s_a, s_b = unpack(s)
            if pt_a == s_a and pt_b == s_b then
                return false
            end
        end
        return true
    end
end

function game_scene.draw()
    -- camera shake
    if game_scene.camera_shake > 0 then
        love.graphics.translate(game_scene.camera_shake-2*love.math.random(game_scene.camera_shake), game_scene.camera_shake-2*love.math.random(game_scene.camera_shake))
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(game_scene.background_img)
    -- draw circle
    love.graphics.setColor(palette[2])
    love.graphics.setLineWidth(4)
    love.graphics.circle("line", CIRCLE_CENTER[1], CIRCLE_CENTER[2], CIRCLE_RADIUS)

    -- draw points
    for _, p in pairs(game_scene.points) do
        love.graphics.circle("fill", p[1], p[2], 5)
    end
    -- draw segments
    if game_scene.invalid_timer > 0 then
        love.graphics.setColor(palette[2])
        love.graphics.setLineWidth(3)
    end

    local pt_a, pt_b
    local x_a, y_a, x_b, y_b
    for _, s in pairs(game_scene.segments) do
        if game_scene.invalid_timer <= 0 then
            -- is this an invalid segment ?
            if util.segment_in_table(s, game_scene.unused) then
                love.graphics.setColor(palette[8])
                love.graphics.setLineWidth(4)
            else
                love.graphics.setColor(palette[6])
                love.graphics.setLineWidth(8)
            end
        end
        pt_a, pt_b = unpack(s)
        x_a, y_a = unpack(game_scene.points[pt_a])
        x_b, y_b = unpack(game_scene.points[pt_b])
        love.graphics.line(x_a, y_a, x_b, y_b)
        love.graphics.circle("fill", x_a, y_a, love.graphics.getLineWidth()/2)
        love.graphics.circle("fill", x_b, y_b, love.graphics.getLineWidth()/2)
    end
    if game_scene.state == 1 then
        x_a, y_a = unpack(game_scene.points[game_scene.last_point])
        x_b, y_b = love.mouse.getPosition()
        love.graphics.setLineWidth(2)
        love.graphics.setColor(palette[8])
        love.graphics.line(x_a, y_a, x_b, y_b)
    end
    -- draw hovered point
    if game_scene.hovered then
        local hx, hy = unpack(game_scene.points[game_scene.hovered])
        love.graphics.setColor(palette[8])
        love.graphics.setLineWidth(1)
        love.graphics.circle("line", hx, hy, HOVER_RADIUS)
    end

    -- draw current validator result
    if game_scene.result then
        love.graphics.setColor(palette[8])
        love.graphics.setFont(fonts.small)
        -- arms
        if game_scene.result[1] > 0 then
            love.graphics.print(game_scene.result[1], 750, 115)
        end
        -- legs
        if game_scene.result[2] > 0 then
            love.graphics.print(game_scene.result[2], 750, 225)
        end
        -- tails
        if game_scene.result[3] > 0 then
            love.graphics.print(game_scene.result[3], 750, 340)
        end
        -- wings
        if game_scene.result[4] then
            love.graphics.draw(graphics.small_tick, 750, 500)
        end
    end

    -- drawing buttons
    if game_scene.state <= 1 then
        for _, b in pairs(game_scene.buttons) do
            b:draw()
        end
    end
    love.graphics.setColor(1, 1, 1)
    if not game_scene.free_mode then
        love.graphics.setFont(fonts.medium)
        -- drawing score
        love.graphics.printf(("%s"):format(game_scene.score), 0, 10, 800, "center")
        -- drawing timer
        love.graphics.setFont(fonts.small)
        love.graphics.setColor(palette[2])
        love.graphics.printf(("%i"):format(math.max(0, game_scene.timer)), 0, 60, 800, "center")
    end

    -- draw overlay for when the demon is drawn
    if game_scene.state >= 3 then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        love.graphics.setColor(1, 1, 1)
    end

    -- draw order
    if not game_scene.free_mode then
        game_scene:draw_order(10, 0)
    end

    -- drawing demon
    if game_scene.state >= 3 then
        demon:draw(400, 300)
    end

    -- pause screen
    if game_scene.paused then
        draw_pause_screen()
    end

    -- pause button
    pause_button:draw()
end

function game_scene:draw_order(x, y)
    local offset_y = -500
    -- entering
    if self.order_state == 1 then
        local t = self.order_anim_timer/ORDER_ENTER_LENGTH
        offset_y = -500*(t^3)
    -- present
    elseif self.order_state == 2 then
        offset_y = 0
    -- exiting
    elseif self.order_state == 3 then
        local t = 1 - self.order_anim_timer/ORDER_EXIT_LENGTH
        offset_y = -500*(t^3)
    end
    love.graphics.push()
    love.graphics.translate(x, y+offset_y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(graphics.order_bg)
    local goal = GOALS[self.goal_idx]
    love.graphics.setColor(palette[2])
    love.graphics.setFont(fonts.medium)
    -- arms
    if goal[1] > 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(graphics.order_arm)
        love.graphics.setColor(palette[1])
        love.graphics.print(goal[1], 20, 45, -0.3)
    end
    -- legs
    if goal[2] > 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(graphics.order_legs)
        love.graphics.setColor(palette[1])
        love.graphics.print(goal[2], 100, 20, -0.3) -- legs
    end
    -- tails
    if goal[3] > 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(graphics.order_tail)
        love.graphics.setColor(palette[1])
        love.graphics.print(goal[3], 80, 150, -0.3) -- tails
    end
    -- wings
    if goal[4] then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(graphics.order_wing)
    end
    -- showing mistakes
    if self.state >= 3 and not self.match then
        love.graphics.setColor(1, 1, 1)
        -- arms
        if goal[1] > 0 and goal[1] ~= self.result[1] then
            love.graphics.draw(graphics.order_circle_arm)
        end
        -- legs
        if goal[2] > 0 and goal[2] ~= self.result[2] then
            love.graphics.draw(graphics.order_circle_legs)
        end
        -- tails
        if goal[3] > 0 and goal[3] ~= self.result[3] then
            love.graphics.draw(graphics.order_circle_tail)
        end
        -- wings
        if goal[4] and not self.result[4] then
            love.graphics.draw(graphics.order_circle_wing)
        end
    end
    -- draw tick or cross mark
    if game_scene.state >= 3 then
        love.graphics.setColor(1, 1, 1)
        local mark
        if game_scene.match then
            mark = graphics.tick
        else
            mark = graphics.cross
        end
        love.graphics.draw(mark, 30, 220)
    end
    love.graphics.translate(0, 0)
    love.graphics.pop()
end

return game_scene
