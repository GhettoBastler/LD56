local palette = require("palette")
local Button = require("button")
local fonts = require("fonts")

local results_scene = {
    score = 0,
    buttons = {}
}

function restart_game()
    scenes.game_scene:enter()
end

function go_to_title()
    scenes.title_scene:enter()
end

function results_scene:enter(score)
    self.score = score

    -- setup buttons
    self.buttons = {}
    table.insert(self.buttons, Button:new("Retry", 200, 300, 400, 80, restart_game, button_colors.pressed, button_colors.released, fonts.small))
    table.insert(self.buttons, Button:new("Title screen", 200, 400, 400, 80, go_to_title, button_colors.pressed, button_colors.released, fonts.small))

    love.update = self.update
    love.draw = self.draw
end

function results_scene.update()
    for _, b in pairs(results_scene.buttons) do
        b:update()
    end
end

function results_scene.draw()
    love.graphics.setFont(fonts.big)
    love.graphics.setColor(palette[8])
    love.graphics.printf(("Time's up!"):format(results_scene.score), 0, 80, 800, "center")
    love.graphics.setFont(fonts.medium)
    love.graphics.printf(("SCORE: %s"):format(results_scene.score), 0, 180, 800, "center")
    for _, b in pairs(results_scene.buttons) do
        b:draw()
    end
end

return results_scene
