local util = require("util")
local palette = require("palette")

local BUTT_POS = {
    {215, 271}, -- no legs
    {244, 285}, -- two legged
    {141, 287} -- four legged
}

local ENTER_ANIM_LENGTH = 30
local EXIT_ANIM_LENGTH = 10

local demon = {
    parts = {
        faces = {
            love.graphics.newImage("gfx/parts/face_1.png"),
            love.graphics.newImage("gfx/parts/face_2.png"),
            love.graphics.newImage("gfx/parts/face_3.png"),
            love.graphics.newImage("gfx/parts/face_4.png"),
            love.graphics.newImage("gfx/parts/face_5.png"),
            love.graphics.newImage("gfx/parts/face_6.png"),
            love.graphics.newImage("gfx/parts/face_7.png"),
        },
        arms = {
            love.graphics.newImage("gfx/parts/arm_1.png"),
            love.graphics.newImage("gfx/parts/arm_2.png"),
            love.graphics.newImage("gfx/parts/arm_3.png"),
            love.graphics.newImage("gfx/parts/arm_4.png"),
            love.graphics.newImage("gfx/parts/arm_5.png"),
            love.graphics.newImage("gfx/parts/arm_6.png"),
            love.graphics.newImage("gfx/parts/arm_7.png"),
            love.graphics.newImage("gfx/parts/arm_8.png"),
        },
        head = love.graphics.newImage("gfx/parts/head.png"),
        legs = {
            love.graphics.newImage("gfx/parts/no_legs.png"),
            love.graphics.newImage("gfx/parts/two_legs.png"),
            love.graphics.newImage("gfx/parts/four_legs.png"),
        },
        wings = love.graphics.newImage("gfx/parts/wings.png"),
        tail = love.graphics.newImage("gfx/parts/tail_1.png"),
    },
    n_arms = 0,
    n_legs = 0,
    n_tails = 0,
    winged = false,
    canvas = love.graphics.newCanvas(480, 434),
    tail_pos = {
        {46, 363},
        {56, 389},
        {349, 364},
        {354, 300},
    },
    anim_timer = 0,
    state = 0 --0: absent, 1: entering, 2: present: 3: exiting
}

local ARM_LEVELS = {
    {1},
    {2, 4, 6, 7, 8},
    {5, 3},
}

function demon:generate(parts)
    self.n_arms, self.n_legs, self.n_tails, self.winged = unpack(parts)
    print(("will generate a monster with: %s pairs of arms, %s pairs of legs, %s tails and %swings"):format(self.n_arms, self.n_legs, self.n_tails, (self.winged and "" or "no ")))
    self.face_idx = love.math.random(#self.parts.faces)
    -- arms idx
    if self.n_arms == 1 then
        self.arm_idx = {1}
    elseif self.n_arms == 2 then
        self.arm_idx = {2, 5}
    elseif self.n_arms == 3 then
        self.arm_idx = {2, 3, 5}
    elseif self.n_arms == 4 then
        self.arm_idx = {2, 3, 4, 5}
    elseif self.n_arms == 5 then
        self.arm_idx = {2, 3, 4, 5, 7}
    elseif self.n_arms == 6 then
        self.arm_idx = {1, 2, 3, 4, 5, 6}
    elseif self.n_arms == 7 then
        self.arm_idx = {1, 2, 3, 4, 5, 6, 7}
    elseif self.n_arms == 8 then
        self.arm_idx = {1, 2, 3, 4, 5, 6, 7, 8}
    else
        self.arm_idx = {}
    end
    if self.n_legs == 0 then
        self.tail_pos = {
            {56, 163},
            {56, 89},
            {349, 164},
            {354, 100},
        }
    else
        self.tail_pos = {
            {56, 363},
            {56, 289},
            {349, 364},
            {354, 300},
        }
    end

    -- drawing on canvas
    -- keeping track of previous canvas
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    -- drawing parts
    -- tail
    if self.n_tails > 0 then
        local butt_x, butt_y = unpack(BUTT_POS[self.n_legs+1])
        local tail_x
        local tail_y
        local cx1, cy1, cx2, cy2, rot
        local bezier
        for i=1, self.n_tails do
            if i == 1 then
                cx1 = -200
                cy1 = 50
                cx2 = 0
                cy2 = 50
            elseif i == 2 then
                cx1 = -100
                cy1 = -80
                cx2 = 20
                cy2 = -20
            elseif i == 3 then
                cx1 = 100
                cy1 = -30
                cx2 = -20
                cy2 = -50
            else
                cx1 = 60
                cy1 = -20
                cx2 = -30
                cy2 = -20
            end
            tail_x, tail_y = unpack(self.tail_pos[i])
            bezier = love.math.newBezierCurve(butt_x, butt_y, butt_x + cx1, butt_y + cy1, tail_x + cx2, tail_y + cy2, tail_x, tail_y)
            love.graphics.setLineWidth(10)
            love.graphics.setColor(palette[6])
            love.graphics.line(bezier:render())
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(self.parts.tail, tail_x, tail_y, 0, 1, 1, 30, 30)
        end
    end
    love.graphics.setColor(1, 1, 1)
    -- wings
    if self.winged then
        love.graphics.draw(self.parts.wings)
    end
    -- legs
    if self.n_legs == 0 then
        love.graphics.draw(self.parts.legs[1])
    elseif self.n_legs == 1 then
        love.graphics.draw(self.parts.legs[2])
    else
        love.graphics.draw(self.parts.legs[3])
    end
    -- arms level 1
    for _, idx in pairs(self.arm_idx) do
        if util.val_in_table(idx, ARM_LEVELS[3]) then
            love.graphics.draw(self.parts.arms[idx])
        end
    end
    -- head
    love.graphics.draw(self.parts.head)
    -- arms level 2
    for _, idx in pairs(self.arm_idx) do
        if util.val_in_table(idx, ARM_LEVELS[2]) then
            love.graphics.draw(self.parts.arms[idx])
        end
    end
    -- face
    love.graphics.draw(self.parts.faces[self.face_idx])
    -- arms level 1
    for _, idx in pairs(self.arm_idx) do
        if util.val_in_table(idx, ARM_LEVELS[1]) then
            love.graphics.draw(self.parts.arms[idx])
        end
    end
    love.graphics.setCanvas(prev_canvas)
    self:enter()
end

function demon:update()
    -- absent
    if self.state == 0 then
        self.anim_timer = 0
    -- entering
    elseif self.state == 1 then
        if self.anim_timer > 0 then
            self.anim_timer = self.anim_timer - 1
        else
            self.state = 2
            self.anim_timer = 0
        end
    -- present
    elseif self.state == 2 then
        self.anim_timer = 0
    -- exiting
    elseif self.state == 3 then
        if self.anim_timer > 0 then
            self.anim_timer = self.anim_timer - 1
        else
            self.state = 0
            self.anim_timer = 0
        end
    end
end

function demon:enter()
    self.anim_timer = ENTER_ANIM_LENGTH 
    self.state = 1
end

function demon:exit()
    self.anim_timer = EXIT_ANIM_LENGTH 
    self.state = 3
end

function demon:draw(x, y)
    local x_offset = self.n_legs == 2 and 0 or -50
    local center_x = (self.canvas:getWidth()+x_offset)/2
    local center_y = self.canvas:getHeight()/2
    -- love.graphics.draw(self.canvas, x + x_offset, y)
    -- entering
    if self.state == 1 then
        local scale_x = util.elastic(1 - self.anim_timer/ENTER_ANIM_LENGTH)
        local scale_y = util.elastic(1 - self.anim_timer/ENTER_ANIM_LENGTH)
        love.graphics.draw(self.canvas, x, y, 0, scale_x, scale_y, center_x, center_y)
    -- present
    elseif self.state == 2 then
        love.graphics.draw(self.canvas, x, y, 0, 1, 1, center_x, center_y)
    -- exiting
    elseif self.state == 3 then
        local t = (1 - self.anim_timer/EXIT_ANIM_LENGTH)
        local offset_x = t^3
        love.graphics.draw(self.canvas, x + 1000*offset_x, y, 0, 1, 1, center_x, center_y)
    end
end

return demon
