local util = require("util")

return {
    main = {
        DARK_BROWN = util.hex_to_col("#432323"),
        LIGHT_BROWN = util.hex_to_col("#FDE0D9"),
        LIGHT_GREEN = util.hex_to_col("#CAF119"),
        DARK_GREEN = util.hex_to_col("#127475"),
    },
    buttons = {
        IDLE_BG = ("#FDE0D9"),
        IDLE_TEXT = ("#432323"),
        PRESSED_BG = ("#CAF119"),
        PRESSED_TEXT = ("#432323"),
    }
}
