local wezterm = require("wezterm")
local keybindings = require("keybindings")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Apply keybindings from the imported file
for k, v in pairs(keybindings) do
	config[k] = v
end

-- Configuration options
config.term = "wezterm"

-- Font
config.font = wezterm.font("DMMono Nerd Font")
config.font_size = 13

-- Decorations
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 10,
	right = 0,
	top = 15,
	bottom = 0,
}
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.85
config.macos_window_background_blur = 10
config.hide_mouse_cursor_when_typing = true
config.initial_cols = 120
config.initial_rows = 30

-- Theme
config.color_scheme = "Kibble"

-- Cursor
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = {
	CubicBezier = {
		0.0,
		0.9,
		0.96,
		1.0,
	},
}
config.cursor_blink_ease_out = {
	CubicBezier = {
		0.0,
		0.9,
		0.96,
		1.0,
	},
}

-- Miscellaneous settings
config.max_fps = 60
config.prefer_egl = true

config.window_close_confirmation = "NeverPrompt"

-- Return the configuration to WezTerm
return config
