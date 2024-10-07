local util = require("util")
local Button = require("button")

local title_scene = {}

function title_scene.start_game()
    scenes.game_scene:enter()
end

function title_scene.start_training()
    scenes.game_scene:enter(true)
end

function title_scene.show_howto()
    scenes.howto_scene:enter()
end

function title_scene:enter()
    -- stop music
    if music:isPlaying() then
        music:stop()
    end
    -- setup buttons
    self.buttons = {
        Button:new("Start game", 200, 250, 400, 80, title_scene.start_game, button_colors.pressed, button_colors.released, fonts.small),
        Button:new("Training", 200, 350, 400, 80, title_scene.start_training, button_colors.pressed, button_colors.released, fonts.small),
        Button:new("How to play", 200, 450, 400, 80, title_scene.show_howto, button_colors.pressed, button_colors.released, fonts.small),
    }
    love.update = self.update
    love.draw = self.draw
end

function title_scene.update()
    for _, b in pairs(title_scene.buttons) do
        b:update()
    end
end

function title_scene.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.big)
    util.draw_centered_text(0, 80, 800, 100, "Eulerian Demons")
    for _, b in pairs(title_scene.buttons) do
        b:draw()
    end
end

return title_scene
