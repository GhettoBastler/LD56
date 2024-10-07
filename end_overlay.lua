local Button = require("button")
local fonts = require("fonts")
local util = require("util")
local palette = require("palette")
local levels = require("levels")

local end_overlay = {
    buttons = {
        Button:new(
            "Retry", 200, 250, 400, 80,
            function()
                SCENES.game_scene:reset()
                -- reset buttons
                for _, b in pairs(SCENES.game_scene.buttons) do
                    b:init()
                end
                SCENES.game_scene.state = "setup"
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Main menu", 200, 450, 400, 80,
            function()
                util.enter_scene(SCENES.title_scene)
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Next level", 200, 350, 400, 80,
            function()
                CURR_LEVEL = CURR_LEVEL + 1
                util.enter_scene(SCENES.game_scene, levels[CURR_LEVEL])
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
    }
}

function end_overlay:update(win)
    for idx=1, (win and #self.buttons or #self.buttons - 1) do
        self.buttons[idx]:update()
    end
end

function end_overlay:draw(win)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 800, 800)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.big)
    local message = win and "Win!" or "Lost!"
    util.draw_centered_text(0, 80, 800, 100, message)
    for idx=1, (win and #self.buttons or #self.buttons - 1) do
        self.buttons[idx]:draw()
    end
end

return end_overlay
