local Button = require("button")
local fonts = require("fonts")
local util = require("util")
local levels = require("levels")
local palette = require("palette")

local level_select_scene = {
    buttons = {
        Button:new(
            "Level 1", 85, 250, 150, 80,
            function()
                -- util.enter_scene(SCENES.game_scene, levels[1])
                CURR_LEVEL = 1
                util.enter_scene(SCENES.game_scene, levels[CURR_LEVEL])
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Level 2", 245, 250, 150, 80,
            function()
                -- util.enter_scene(SCENES.game_scene, levels[2])
                CURR_LEVEL = 2
                util.enter_scene(SCENES.game_scene, levels[CURR_LEVEL])
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Level 3", 405, 250, 150, 80,
            function()
                -- util.enter_scene(SCENES.game_scene, levels[3])
                CURR_LEVEL = 3
                util.enter_scene(SCENES.game_scene, levels[CURR_LEVEL])
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Level 4", 565, 250, 150, 80,
            function()
                -- util.enter_scene(SCENES.game_scene, levels[4])
                CURR_LEVEL = 4
                util.enter_scene(SCENES.game_scene, levels[CURR_LEVEL])
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Level 5", 85, 350, 150, 80,
            function()
                -- util.enter_scene(SCENES.game_scene, levels[5])
                CURR_LEVEL = 5
                util.enter_scene(SCENES.game_scene, levels[CURR_LEVEL])
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Level 6", 245, 350, 150, 80,
            function()
                -- util.enter_scene(SCENES.game_scene, levels[6])
                CURR_LEVEL = 6
                util.enter_scene(SCENES.game_scene, levels[CURR_LEVEL])
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Level 7", 405, 350, 150, 80,
            function()
                -- util.enter_scene(SCENES.game_scene, levels[7])
                CURR_LEVEL = 7
                util.enter_scene(SCENES.game_scene, levels[CURR_LEVEL])
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
        Button:new(
            "Level 8", 565, 350, 150, 80,
            function()
                -- util.enter_scene(SCENES.game_scene, levels[8])
                CURR_LEVEL = 8
                util.enter_scene(SCENES.game_scene, levels[CURR_LEVEL])
            end,
            {palette.buttons.PRESSED_TEXT, palette.buttons.PRESSED_BG},
            {palette.buttons.IDLE_TEXT, palette.buttons.IDLE_BG},
            fonts.small
        ),
    }
}

function level_select_scene:init()
    -- initialize buttons
    for _, button in pairs(self.buttons) do
        button:init()
    end
end

function level_select_scene:update()
    for _, button in pairs(self.buttons) do
        button:update()
    end
end

function level_select_scene:draw()
    love.graphics.setColor(util.hex_to_col("#ffffff"))
    love.graphics.setFont(fonts.big)
    util.draw_centered_text(0, 80, 800, 100, "Level selection")
    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

return level_select_scene
