local wezterm = require("wezterm")
local act = wezterm.action
local kb = require("keybindings")

local config = wezterm.config_builder()

-- === Перфоманс/рендер ===
-- Если WebGPU доступен — обычно даёт +fps и меньшую нагрузку
config.front_end = "WebGpu" -- fallback: "OpenGL"
config.prefer_egl = true
config.max_fps = 120
config.animation_fps = 120
config.scrollback_lines = 15000
config.check_for_updates = false

-- === Шрифт ===
-- C фоллбэком на случай отсутствия nerd-шрифта
config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"0xProto Nerd Font",
	"Monaco",
})
config.harfbuzz_features = { "calt=1", "liga=1", "clig=1", "zero" }
config.use_cap_height_to_scale_fallback_fonts = true
config.font_size = 14

-- === Окно ===
config.window_padding = { left = 10, right = 0, top = 15, bottom = 0 }
config.window_decorations = "TITLE|RESIZE" -- можно "INTEGRATED_BUTTONS|RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.96
config.macos_window_background_blur = 4
config.initial_cols = 140
config.initial_rows = 35
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.85 }

-- === Курсор/колокол ===
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 450
config.force_reverse_video_cursor = true
config.audible_bell = "Disabled"
config.visual_bell = { fade_in_duration_ms = 50, fade_out_duration_ms = 50 }

-- === macOS клавиши ===
-- Левый Option вводит символы, правый — Meta (удобно для tmux/vim)
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

-- === Авто-светлая/тёмная тема ===

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Google (dark) (terminal.sexy)"
	else
		return "Google (light) (terminal.sexy)"
	end
end
-- Если когда-нибудь это будет работать нормально в связке с Astronvim — раскомментировать строку.
-- А пока просто жёстко устанавливаем одну тему и для дня, и для ночи
-- config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.color_scheme = "Google (dark) (terminal.sexy)"

-- === Вкладки ===

wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
	local idx = tab.tab_index + 1
	local title = tab.active_pane.title:gsub("^%s*(.-)%s*$", "%1")
	return { { Text = " " .. idx .. ": " .. title .. " " } }
end)

-- === Workspaces ===

wezterm.on("switch-workspace-prompt", function(window, _)
	window:perform_action(
		act.PromptInputLine({
			description = "Workspace name:",
			action = wezterm.action_callback(function(win, _, line)
				if line and #line > 0 then
					win:perform_action(act.SwitchToWorkspace({ name = line }), _)
				end
			end),
		}),
		_
	)
end)

-- === Привязки клавиш в отдельном модуле ===
for k, v in pairs(kb) do
	config[k] = v
end

-- === Мелочи ===
config.automatically_reload_config = true
config.window_close_confirmation = "NeverPrompt"
config.enable_kitty_graphics = true

-- === Прокси ===
config.set_environment_variables = {
	HTTP_PROXY = "http://127.0.0.1:2080",
	HTTPS_PROXY = "http://127.0.0.1:2080",
	ALL_PROXY = "socks5://127.0.0.1:2080",
	NO_PROXY = "localhost,127.0.0.1,.local",
}

-- Вернуть всю эту конфигурацию в WezTerm
return config
