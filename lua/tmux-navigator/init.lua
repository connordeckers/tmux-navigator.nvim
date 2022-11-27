-- Replicates the tmux-aware navigation of
-- github.com/christoomey/vim-tmux-navigator/blob/master/plugin/tmux_navigator.vim
local tmux = require("tmux-navigator.controls")

local T = {}

---@param config TmuxIntegrationConfig
function T.setup(config)
	---@diagnostic disable-next-line: invisible
	local cfg = require("tmux-navigator.config"):set(config):get()

	local TmuxNavWatcher = vim.api.nvim_create_augroup("TmuxNavigator", {})
	vim.api.nvim_clear_autocmds({ group = TmuxNavWatcher })

	-- If it's not enabled, no need to do anything else.
	if not cfg.enabled then
		return cfg
	end

	-- Hook up here --

	local keymap_opts = { noremap = true, silent = true }
	local keymap = {
		["<C-h>"] = tmux.navigate.left, -- Move left
		["<C-j>"] = tmux.navigate.down, -- Move down
		["<C-k>"] = tmux.navigate.up, -- Move up
		["<C-l>"] = tmux.navigate.right, -- Move right
		["<C-p>"] = tmux.navigate.previous, -- Move to previous pane
	}
	-- Note whenever we enter a window that our previous action won't go to tmux.
	-- This helps us remember where "previous" actually is.
	vim.api.nvim_create_autocmd("WinEnter", {
		group = TmuxNavWatcher,
		callback = function()
			tmux.WasLastPane = false
		end,
	})

	if not cfg.DisableMapping then
		for map, action in pairs(keymap) do
			vim.keymap.set("n", map, action, keymap_opts)
		end
	end

	-- Return the config and move on
	return cfg
end

return T
