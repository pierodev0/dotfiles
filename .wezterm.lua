local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

-- Crear objeto config
local config = wezterm.config_builder()


-- Iniciar ventana maximizada al abrir WezTerm
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- =====================
-- BASIC CONFIG
-- =====================
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.color_scheme = "Tokyo Night" -- Macchiato, Frappe, Latte
config.default_prog = { "pwsh.exe" }

-- Ventana
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.hide_tab_bar_if_only_one_tab = true

-- =====================
-- TMUX-LIKE LEADER
-- =====================
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

-- =====================
-- KEYBINDINGS
-- =====================
config.keys = {
	-- =====================
	-- PANE MANAGEMENT
	-- =====================
	{ key = "%", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = '"', mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	{
		key = "x",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

	-- =====================
	-- PANE NAVIGATION
	-- =====================
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- =====================
	-- RESIZE PANES
	-- =====================
	{ key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

	-- =====================
	-- TABS
	-- =====================
	{
		key = "c",
		mods = "LEADER",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

	{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = act.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = act.ActivateTab(4) },

	-- =====================
	-- MISC
	-- =====================
	{ key = "F11", action = act.ToggleFullScreen },
	{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },
	{ key = "?", mods = "LEADER", action = act.ShowDebugOverlay },
}

-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end

local function is_vim(pane)
  -- This gsub is equivalent to POSIX basename(3)
  -- Given "/foo/bar" returns "bar"
  -- Given "c:\\foo\\bar" returns "bar"
  local process_name = string.gsub(pane:get_foreground_process_name(), '(.*[/\\])(.*)', '%2')
  return process_name == 'nvim' or process_name == 'vim'
end

local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

-- Configuración de teclas
for _, key in ipairs({ 'h', 'j', 'k', 'l' }) do
  table.insert(config.keys, split_nav('move', key))
end

for _, key in ipairs({ 'h', 'j', 'k', 'l' }) do
  table.insert(config.keys, split_nav('resize', key))
end
return config

