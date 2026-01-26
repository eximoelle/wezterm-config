local wezterm = require("wezterm")
local act = wezterm.action

-- Сокращает длинные пути для статуса: /a/b/c/d -> /a/…/c/d
local function shorten_path(path)
	if not path or #path == 0 then
		return ""
	end

	local home = wezterm.home_dir
	if home and path:find(home, 1, true) == 1 then
		path = path:gsub("^" .. home, "~")
	end

	local prefix = path:sub(1, 1) == "/" and "/" or ""
	local segments = {}
	for part in path:gmatch("[^/]+") do
		table.insert(segments, part)
	end

	if #segments <= 3 then
		return path
	end

	-- Оставляем корень, два последних сегмента и многоточие, чтобы статус не разрастался
	return prefix .. table.concat({ segments[1], "…", segments[#segments - 1], segments[#segments] }, "/")
end

-- Правый статус-бар
wezterm.on("update-right-status", function(window, pane)
	local cwd_uri = pane:get_current_working_dir()
	local cwd = cwd_uri and shorten_path(cwd_uri.file_path) or ""

	local host = wezterm.hostname()
	local ws = window:active_workspace()
	local time = wezterm.strftime("%Y-%m-%d %H:%M")

	window:set_right_status(wezterm.format({
		{ Text = " " .. ws .. " " },
		{ Text = "| " .. host .. " " },
		{ Text = "| " .. time .. " " },
		{ Text = "| " .. cwd .. " " },
	}))
end)

-- Заголовки табов
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local pane = tab.active_pane
	local title = (tab.tab_title and tab.tab_title ~= "") and tab.tab_title or pane.title

	local idx = (tab.tab_index or 0) + 1
	local prefix = tostring(idx) .. ": "

	local max = math.max(10, max_width - 3)
	if #title > max then
		title = title:sub(1, max - 1) .. "…"
	end

	return prefix .. title
end)

return {
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },

	keys = {
		-- Панели (splits)
		{ key = "-",         mods = "LEADER",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "\\",        mods = "LEADER",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

		{ key = "z",          mods = "LEADER",       action = act.TogglePaneZoomState },
		{ key = "q",          mods = "LEADER",       action = act.CloseCurrentPane({ confirm = true }) },

		{ key = "g",          mods = "LEADER",       action = act.PaneSelect },
		{ key = "{",          mods = "LEADER|SHIFT", action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }) },

		-- Модальные режимы для работы с панелями
		{ key = "r",          mods = "LEADER",       action = act.ActivateKeyTable({ name = "resize_mode", one_shot = false }) },
		{ key = "m",          mods = "LEADER",       action = act.ActivateKeyTable({ name = "pane_mode", one_shot = false }) },

		-- Симметрия с nvim: Ctrl = фокус
		{ key = "h",          mods = "CTRL",         action = act.ActivatePaneDirection("Left") },
		{ key = "j",          mods = "CTRL",         action = act.ActivatePaneDirection("Down") },
		{ key = "k",          mods = "CTRL",         action = act.ActivatePaneDirection("Up") },
		{ key = "l",          mods = "CTRL",         action = act.ActivatePaneDirection("Right") },

		-- Симметрия с nvim: Alt = ресайз
		{ key = "h",          mods = "ALT",          action = act.AdjustPaneSize({ "Left", 3 }) },
		{ key = "j",          mods = "ALT",          action = act.AdjustPaneSize({ "Down", 2 }) },
		{ key = "k",          mods = "ALT",          action = act.AdjustPaneSize({ "Up", 2 }) },
		{ key = "l",          mods = "ALT",          action = act.AdjustPaneSize({ "Right", 3 }) },

		{ key = "LeftArrow",  mods = "ALT",          action = act.AdjustPaneSize({ "Left", 3 }) },
		{ key = "DownArrow",  mods = "ALT",          action = act.AdjustPaneSize({ "Down", 2 }) },
		{ key = "UpArrow",    mods = "ALT",          action = act.AdjustPaneSize({ "Up", 2 }) },
		{ key = "RightArrow", mods = "ALT",          action = act.AdjustPaneSize({ "Right", 3 }) },

		-- Табы
		{ key = "c",          mods = "LEADER",       action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "x",          mods = "LEADER",       action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "n",          mods = "LEADER",       action = act.ActivateTabRelative(1) },
		{ key = "p",          mods = "LEADER",       action = act.ActivateTabRelative(-1) },

		table.unpack((function()
			local t = {}
			for i = 1, 9 do
				table.insert(t, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
			end
			return t
		end)()),

		-- Поиск и копирование
		{ key = "v", mods = "LEADER",       action = act.ActivateCopyMode },
		{ key = "f", mods = "LEADER",       action = act.Search("CurrentSelectionOrEmptyString") },
		{ key = " ", mods = "LEADER",       action = act.QuickSelect },

		-- Workspaces
		{ key = "w", mods = "LEADER",       action = act.EmitEvent("switch-workspace-prompt") },

		-- Командные интерфейсы
		{ key = "P", mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },
		{ key = "L", mods = "LEADER|SHIFT", action = act.ShowLauncher },

		-- Новый shell
		{ key = "s", mods = "LEADER",       action = act.SpawnCommandInNewTab({ args = { os.getenv("SHELL") or "zsh" } }) },

		-- Переключение прозрачности
		{
			key = "o",
			mods = "LEADER",
			action = wezterm.action_callback(function(win, _)
				local a = win:get_config_overrides() or {}
				a.window_background_opacity = (a.window_background_opacity == 1.0) and 0.92 or 1.0
				win:set_config_overrides(a)
			end),
		},

		-- macOS-привычки
		{ key = "t",     mods = "CMD",       action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "w",     mods = "CMD",       action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "w",     mods = "CMD|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "Enter", mods = "CMD",       action = act.ToggleFullScreen },
		{ key = "[",     mods = "CMD",       action = act.ActivateTabRelative(-1) },
		{ key = "]",     mods = "CMD",       action = act.ActivateTabRelative(1) },
	},

	key_tables = {
		resize_mode = {
			-- Режим ресайза, выход по Esc/Enter
			{ key = "h",          action = act.AdjustPaneSize({ "Left", 3 }) },
			{ key = "j",          action = act.AdjustPaneSize({ "Down", 2 }) },
			{ key = "k",          action = act.AdjustPaneSize({ "Up", 2 }) },
			{ key = "l",          action = act.AdjustPaneSize({ "Right", 3 }) },

			{ key = "LeftArrow",  action = act.AdjustPaneSize({ "Left", 3 }) },
			{ key = "DownArrow",  action = act.AdjustPaneSize({ "Down", 2 }) },
			{ key = "UpArrow",    action = act.AdjustPaneSize({ "Up", 2 }) },
			{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 3 }) },

			{ key = "Escape",     action = "PopKeyTable" },
			{ key = "Enter",      action = "PopKeyTable" },
		},

		pane_mode = {
			-- Фокус
			{ key = "h",      action = act.ActivatePaneDirection("Left") },
			{ key = "j",      action = act.ActivatePaneDirection("Down") },
			{ key = "k",      action = act.ActivatePaneDirection("Up") },
			{ key = "l",      action = act.ActivatePaneDirection("Right") },

			-- Ресайз (Shift+hjkl)
			{ key = "H",      action = act.AdjustPaneSize({ "Left", 3 }) },
			{ key = "J",      action = act.AdjustPaneSize({ "Down", 2 }) },
			{ key = "K",      action = act.AdjustPaneSize({ "Up", 2 }) },
			{ key = "L",      action = act.AdjustPaneSize({ "Right", 3 }) },

			-- Перестановки/ротации
			{ key = "g",      action = act.PaneSelect },
			{ key = "{",      action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }) },
			{ key = "R",      action = act.RotatePanes("Clockwise") },

			-- Быстрые операции
			{ key = "z",      action = act.TogglePaneZoomState },
			{ key = "q",      action = act.CloseCurrentPane({ confirm = true }) },

			{ key = "Escape", action = "PopKeyTable" },
			{ key = "Enter",  action = "PopKeyTable" },
		},
	},

	mouse_bindings = {
        {
            -- Копирование в буфер правой кнопкой мыши
              event = { Up = { streak = 1, button = "Right" } },
              mods = "NONE",
              action = wezterm.action.CopyTo "Clipboard",
            },
	},
}
