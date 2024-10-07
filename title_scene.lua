local Button = require("button")
local fonts = require("fonts")
local util = require("util")
local levels = require("levels")
local palette = require("palette")

local title_scene = {
    buttons = {
        Button:new(
            "Play", 200, 400, 400, 80,
            function()
                util.enter_scene(SCENES.level_select_scene, levels[1])
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
    }
}

function title_scene:init()
    -- initialize buttons
    for _, button in pairs(self.buttons) do
        button:init()
    end
end

function title_scene:update()
    for _, button in pairs(self.buttons) do
        button:update()
    end
end

function title_scene:draw()
    love.graphics.setColor(util.hex_to_col("#ffffff"))
    love.graphics.setFont(fonts.big)
    util.draw_centered_text(0, 80, 800, 100, "SOKOBEETLES")
    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

return title_scene
