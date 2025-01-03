local wezterm = require("wezterm")
local io = require("io")

-- Theme variables for easy customization
local themes = {
	dark = {
		wezterm = "Everforest Dark Soft (Gogh)",
		neovim = "everforest",
	},
	light = {
		wezterm = "Everforest Light (Gogh)",
		neovim = "everforest_light",
	},
}

-- Utility function to read and modify a file
local function modify_file(file_path, modify_callback)
	local lines = {}
	local file = io.open(file_path, "r")
	if not file then
		wezterm.log_error("Failed to read file: " .. file_path)
		return
	end

	for line in file:lines() do
		table.insert(lines, modify_callback(line) or line)
	end
	file:close()

	file = io.open(file_path, "w")
	if not file then
		wezterm.log_error("Failed to write file: " .. file_path)
		return
	end

	for _, line in ipairs(lines) do
		file:write(line .. "\n")
	end
	file:close()
end

-- Function to update the theme in Neovim config
local function update_neovim_theme(theme)
	local neovim_config_path = os.getenv("HOME") .. "/.config/nvim/lua/chadrc.lua"
	local inside_base46 = false

	modify_file(neovim_config_path, function(line)
		if line:find("^M%.base46%s*=%s*{") then
			inside_base46 = true
		elseif line:find("^}") and inside_base46 then
			inside_base46 = false
		end

		if inside_base46 and line:find("theme%s*=%s*") then
			return string.format([[	theme = "%s",]], theme)
		end
	end)
end

-- Function to get the theme based on appearance
local function get_theme_for_appearance(appearance)
	if appearance:find("Dark") then
		return themes.dark
	else
		return themes.light
	end
end

-- Exported API
return {
	get_theme_for_appearance = get_theme_for_appearance,
	update_neovim_theme = update_neovim_theme,
}
