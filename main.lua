local palette = require("palette")

scenes = {}
music = nil
music_on = false
button_colors = {
    pressed = {palette[1], palette[7]},
    released = {palette[8], palette[1]},
}

function love.load()
    love.graphics.setBackgroundColor(palette[2])

    music = love.audio.newSource("sfx/loop.wav", "stream")
    music:setLooping(true)
    scenes.title_scene = require("title_scene")
    scenes.game_scene = require("game_scene")
    scenes.results_scene = require("results_scene")
    scenes.howto_scene = require("howto")
    scenes.title_scene:enter()
end
