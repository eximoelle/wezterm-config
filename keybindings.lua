local wezterm = require("wezterm")

-- Define custom keybindings
-- List all available actions: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html
local keybindings = {
	keys = {
		{
			key = "w",
			mods = "CMD",
			action = wezterm.action.CloseCurrentPane({ confirm = true }),
		},
	},
}

return keybindings
