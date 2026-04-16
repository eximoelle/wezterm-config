local wezterm = require("wezterm")
local act = wezterm.action

local function is_vim(pane)
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
	LeftArrow = "Left",
	DownArrow = "Down",
	UpArrow = "Up",
	RightArrow = "Right",
}

local function split_nav(key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				win:perform_action({ SendKey = { key = key, mods = "CTRL" } }, pane)
			else
				win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
			end
		end),
	}
end

return {
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },

	keys = {
		-- Панели (splits)
		{ key = "\\",         mods = "LEADER",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-",          mods = "LEADER",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

		{ key = "z",          mods = "LEADER",       action = act.TogglePaneZoomState },
		{ key = "q",          mods = "LEADER",       action = act.CloseCurrentPane({ confirm = true }) },

		{ key = "g",          mods = "LEADER",       action = act.PaneSelect },
		{ key = "{",          mods = "LEADER|SHIFT", action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }) },

		-- Модальные режимы для работы с панелями
		{ key = "r",          mods = "LEADER",       action = act.ActivateKeyTable({ name = "resize_mode", one_shot = false }) },
		{ key = "m",          mods = "LEADER",       action = act.ActivateKeyTable({ name = "pane_mode", one_shot = false }) },

		-- Умная интеграция с nvim: внутри nvim клавиши проходят в редактор, вне nvim управляют pane WezTerm
		split_nav("h"),
		split_nav("j"),
		split_nav("k"),
		split_nav("l"),

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
		{ key = "UpArrow", mods = "SHIFT",  action = act.ScrollToPrompt(-1) },
		{ key = "DownArrow", mods = "SHIFT", action = act.ScrollToPrompt(1) },

		-- Workspaces
		{ key = "w", mods = "LEADER",       action = act.EmitEvent("switch-workspace-prompt") },

		-- Командные интерфейсы
		{ key = "P", mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },
		{
			key = "L",
			mods = "LEADER|SHIFT",
			action = act.ShowLauncherArgs({
				flags = "FUZZY|TABS|WORKSPACES|DOMAINS",
				title = "Tabs, Workspaces & SSH",
			}),
		},

		-- Новый shell
		{ key = "s", mods = "LEADER",       action = act.SpawnCommandInNewTab({ args = { os.getenv("SHELL") or "zsh" } }) },

		-- Переключение прозрачности
			{
				key = "o",
				mods = "LEADER",
				action = wezterm.action_callback(function(win, _)
					local a = win:get_config_overrides() or {}
					a.window_background_opacity = (a.window_background_opacity == 1.0) and 0.96 or 1.0
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
