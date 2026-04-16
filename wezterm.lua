local wezterm = require("wezterm")
local act = wezterm.action
local kb = require("keybindings")

local config = wezterm.config_builder()
local local_hostname = wezterm.hostname()
config.ssh_domains = wezterm.default_ssh_domains()

for _, dom in ipairs(config.ssh_domains) do
	if dom.multiplexing == "None" then
		dom.assume_shell = "Posix"
	end
end

local ssh_opts_with_arg = {
	["-B"] = true,
	["-b"] = true,
	["-c"] = true,
	["-D"] = true,
	["-E"] = true,
	["-e"] = true,
	["-F"] = true,
	["-I"] = true,
	["-i"] = true,
	["-J"] = true,
	["-L"] = true,
	["-l"] = true,
	["-m"] = true,
	["-O"] = true,
	["-o"] = true,
	["-p"] = true,
	["-Q"] = true,
	["-R"] = true,
	["-S"] = true,
	["-W"] = true,
	["-w"] = true,
}

local function basename(path)
	if not path or path == "" then
		return ""
	end
	return path:gsub("(.*[/\\])(.*)", "%2")
end

local function normalize_host(host)
	if not host or host == "" then
		return nil
	end
	return host:gsub("%.$", ""):lower()
end

local function same_host(a, b)
	a = normalize_host(a)
	b = normalize_host(b)
	if not a or not b then
		return false
	end
	if a == b then
		return true
	end
	return a:match("^[^.]+") == b:match("^[^.]+")
end

local function ssh_destination_from_argv(argv)
	if not argv or #argv == 0 or basename(argv[1]) ~= "ssh" then
		return nil
	end

	local i = 2
	while i <= #argv do
		local arg = argv[i]
		if arg == "--" then
			return argv[i + 1]
		end

		if not arg:match("^%-") then
			return arg
		end

		if ssh_opts_with_arg[arg] then
			i = i + 2
		elseif arg:match("^%-[%a].+") and ssh_opts_with_arg["-" .. arg:sub(2, 2)] then
			i = i + 1
		else
			i = i + 1
		end
	end

	return nil
end

local function remote_host_from_shell_integration(pane)
	local user_vars = pane:get_user_vars() or {}
	local host = user_vars.WEZTERM_HOST
	local cwd_uri = pane:get_current_working_dir()

	if cwd_uri and cwd_uri.host and cwd_uri.host ~= "" then
		host = cwd_uri.host
	end

	if host and not same_host(host, local_hostname) then
		return host
	end

	return nil
end

local function ssh_label_from_domain_name(name)
	if not name or name == "" or name == "local" then
		return nil
	end

	local host = name:match("^SSH:([^%s]+)$")
	if host then
		return "SSH " .. host
	end

	host = name:match("^SSHMUX:([^%s]+)$")
	if host then
		return "SSHMUX " .. host
	end

	return nil
end

local function ssh_label_for_pane(pane)
	local domain_label = ssh_label_from_domain_name(pane:get_domain_name())
	if domain_label then
		return domain_label
	end

	local remote_host = remote_host_from_shell_integration(pane)
	if remote_host then
		return "SSH " .. remote_host
	end

	if basename(pane:get_foreground_process_name()) ~= "ssh" then
		return nil
	end

	local info = pane:get_foreground_process_info()
	local target = info and ssh_destination_from_argv(info.argv)
	if target and target ~= "" then
		return "SSH " .. target
	end

	return "SSH"
end

local function basename_from_uri_path(path)
	if not path or path == "" then
		return nil
	end

	local trimmed = path:gsub("/+$", "")
	if trimmed == "" then
		return "/"
	end

	local leaf = trimmed:match("([^/]+)$")
	return leaf or trimmed
end

local function cwd_label_for_pane(pane)
	local cwd_uri = pane:get_current_working_dir()
	if not cwd_uri then
		return nil
	end

	if cwd_uri.file_path and cwd_uri.file_path ~= "" then
		return basename_from_uri_path(cwd_uri.file_path)
	end

	if cwd_uri.path and cwd_uri.path ~= "" then
		return basename_from_uri_path(cwd_uri.path)
	end

	return nil
end

local function status_cells_for_pane(window, pane)
	local cells = {}
	local ssh_label = ssh_label_for_pane(pane)
	if ssh_label then
		table.insert(cells, { text = ssh_label, bg = "#7c2d12", fg = "#fff7ed" })
	end

	local workspace = window:active_workspace()
	if workspace and workspace ~= "" then
		table.insert(cells, { text = "WS " .. workspace, bg = "none", fg = "#f8fafc" })
	end

	local cwd = cwd_label_for_pane(pane)
	if cwd then
		table.insert(cells, { text = "DIR " .. cwd, bg = "none", fg = "#f8fafc" })
	end

	return cells
end

local function format_status(cells)
	if #cells == 0 then
		return ""
	end

	local elements = {}
	for _, cell in ipairs(cells) do
		table.insert(elements, { Background = { Color = cell.bg or "none" } })
		table.insert(elements, { Foreground = { Color = cell.fg } })
		table.insert(elements, { Text = " " .. cell.text .. " " })
	end

	table.insert(elements, "ResetAttributes")
	table.insert(elements, { Text = "  " })

	return wezterm.format(elements)
end

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
	"Lilex Nerd Font",
	"JetBrainsMono Nerd Font",
	"0xProto Nerd Font",
	"Monaco",
})
config.harfbuzz_features = { "calt=1", "liga=1", "clig=1", "zero" }
config.use_cap_height_to_scale_fallback_fonts = true
config.font_size = 14

-- === Окно ===
config.window_padding = { left = 5, right = 5, top = 5, bottom = 5 }
config.window_decorations = "TITLE|RESIZE" -- можно "INTEGRATED_BUTTONS|RESIZE"
config.hide_tab_bar_if_only_one_tab = false
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

config.color_scheme = 'Derp (terminal.sexy)'

-- === Workspaces ===

wezterm.on("update-status", function(window, pane)
	window:set_right_status(format_status(status_cells_for_pane(window, pane)))
end)

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

-- Вернуть всю эту конфигурацию в WezTerm
return config
