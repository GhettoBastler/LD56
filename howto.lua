local palette = require("palette")

local howto = {
    state = 0,
    pages = {
        love.graphics.newImage("gfx/howto/1.png"),
        love.graphics.newImage("gfx/howto/2.png"),
        love.graphics.newImage("gfx/howto/3.png"),
        love.graphics.newImage("gfx/howto/4.png"),
    }
}

function howto:enter()
    self.state = 0
    self.released = false

    love.update = self.update
    love.draw = self.draw
end

function howto.update()
    if not love.mouse.isDown(1) then
        howto.released = true
    end
    if howto.released and love.mouse.isDown(1) then
        if howto.state < 3 then
            howto.released = false
            howto.state = howto.state + 1
        else
            scenes.title_scene:enter()
        end
    end
end

function howto.draw()
    love.graphics.setColor(palette[8])
    love.graphics.draw(howto.pages[howto.state+1])
end

return howto
