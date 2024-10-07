local Button = require("button")
local fonts = require("fonts")
local util = require("util")
local palette = require("palette")

local pause_overlay = {
    buttons = {
        Button:new(
            "Clear", 200, 250, 400, 80,
            function()
                util.enter_scene(SCENES.game_scene)
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Main menu", 200, 350, 400, 80,
            function()
                util.enter_scene(SCENES.title_scene)
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Return", 200, 450, 400, 80,
            function()
                SCENES.game_scene.state = "playing"
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
    }
}

function pause_overlay:update()
    for _, button in pairs(self.buttons) do
        button:update()
    end
end

function pause_overlay:draw()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 800, 800)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.big)
    util.draw_centered_text(0, 80, 800, 100, "Paused")
    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

return pause_overlay
