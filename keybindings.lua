local wezterm = require("wezterm")
local act = wezterm.action

return {
	-- Leader как в tmux: Ctrl+a, задержка на ввод 1700 мс
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1700 },

	keys = {
		-- ===== Панели (splits) =====
		{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

		-- Навигация по панелям (vim-стайл)
		{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
		{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
		{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
		{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

		-- Изменение размеров панелей (Leader + Shift + стрелки)
		{ key = "LeftArrow", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 3 }) },
		{ key = "RightArrow", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
		{ key = "UpArrow", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 2 }) },
		{ key = "DownArrow", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 2 }) },

		-- Зум активной панели
		{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

		-- ===== Табы =====
		{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "x", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
		{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

		-- Быстрый выбор табов: Leader + 1..9
		table.unpack((function()
			local t = {}
			for i = 1, 9 do
				table.insert(t, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
			end
			return t
		end)()),

		-- ===== Поиск/копирование =====
		{ key = "v", mods = "LEADER", action = act.ActivateCopyMode },
		{ key = "f", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") },

		-- ===== Workspaces =====
		{ key = "w", mods = "LEADER", action = act.EmitEvent("switch-workspace-prompt") },

		-- Быстрый shell в новом табе
		{ key = "s", mods = "LEADER", action = act.SpawnCommandInNewTab({ args = { os.getenv("SHELL") or "zsh" } }) },

		-- Переключатель прозрачности
		{
			key = "o",
			mods = "LEADER",
			action = wezterm.action_callback(function(win, _)
				local a = win:get_config_overrides() or {}
				a.window_background_opacity = (a.window_background_opacity == 1.0) and 0.92 or 1.0
				win:set_config_overrides(a)
			end),
		},

		-- ===== macOS-переводы привычек (Cmd) =====
		{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "Enter", mods = "CMD", action = act.ToggleFullScreen },
		{ key = "[", mods = "CMD", action = act.ActivateTabRelative(-1) },
		{ key = "]", mods = "CMD", action = act.ActivateTabRelative(1) },
	},

	-- Мышь без Alt-завязок
	mouse_bindings = {
		-- Двойной клик = выделение слова, тройной = строки (поведение по умолчанию сохраняется)
	},
}
