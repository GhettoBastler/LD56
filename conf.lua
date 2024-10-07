function love.conf(t) 
    t.identity = "ld55"
    t.window.width = 800
    t.window.height = 600
    t.modules.joystick = false  -- or else the game won't run in a mobile browser
    t.modules.physics = false            -- Enable the physics module (boolean)
    t.modules.thread = false             -- Enable the thread module (boolean)
    t.modules.video = false              -- Enable the video module (boolean)
end
