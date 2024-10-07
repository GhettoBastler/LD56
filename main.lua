local util = require("util")
local palette = require("palette")

SCENES = {}
CURR_LEVEL = 1

function love.load()
    -- loading scenes
    SCENES.title_scene = require("title_scene")
    SCENES.level_select_scene = require("level_select_scene")
    SCENES.game_scene = require("game_scene")

    -- global background color
    love.graphics.setBackgroundColor(palette.main.DARK_BROWN)

    -- entering first scene
    util.enter_scene(SCENES.title_scene)
end
