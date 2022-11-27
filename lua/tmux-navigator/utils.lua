local util = {}
local str_util = {}

str_util.trim = function(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

str_util.split = function(search, sep)
	sep = sep == nil and "%s" or sep
	local matches = {}

	for str in string.gmatch(search, "([^" .. sep .. "]+)") do
		table.insert(matches, str)
	end

	return matches
end

function util.tmux_info()
	return os.getenv("TMUX")
end

function util.socket_path()
	local info = util.tmux_info()
	return info ~= nil and str_util.split(info, ",")[1] or nil
end

function util.is_tmux()
	return util.tmux_info() ~= nil
end

function util.path()
	if not util.is_tmux() then
		return nil
	end

	local info = util.tmux_info()
	return info ~= nil and string.find(info, "tmate") and "tmate" or "tmux"
end

function util.exec(args)
	if not util.is_tmux() then
		return nil
	end

	local exec = util.path()
	local params = { "-S", util.socket_path(), args }

	local cmd = exec .. " " .. table.concat(params, " ")

	local output = vim.fn.trim(vim.fn.system(cmd))
	local exitcode = vim.v.shell_error

	return output, exitcode
end

-- Convert vim direction to tmux direction
local keymap = {
	h = "left",
	j = "bottom",
	k = "top",
	l = "right",
}

-- Convert vim direction to tmux direction
---@param direction "h" | "j" | "k" | "l" | "p"
function util.pane_position_from_direction(direction)
	return keymap[direction] or nil
end

local tmuxmap = {
	p = "l",
	h = "L",
	j = "D",
	k = "U",
	l = "R",
}
-- Convert vim direction to tmux selector
---@param direction "h" | "j" | "k" | "l" | "p"
function util.vim_direction_to_select_pane_direction(direction)
	return tmuxmap[direction] or nil
end

local navigate = {
	nvim = {
		-- Navigate to the neovim panel on the left
		left = function()
			vim.cmd("wincmd h")
		end,

		-- Navigate to the neovim panel below
		down = function()
			vim.cmd("wincmd j")
		end,

		-- Navigate to the neovim panel above
		up = function()
			vim.cmd("wincmd k")
		end,

		-- Navigate to the neovim panel to the right
		right = function()
			vim.cmd("wincmd l")
		end,

		-- Navigate to the previously used neovim pane
		previous = function()
			vim.cmd("wincmd p")
		end,
	},
	tmux = {},
}

navigate.nvim.h = navigate.nvim.left
navigate.nvim.j = navigate.nvim.down
navigate.nvim.k = navigate.nvim.up
navigate.nvim.l = navigate.nvim.right

util.navigate = navigate

function util.save_one()
	local write = function()
		vim.cmd("update")
	end

	local try_write, err = pcall(write)
	return try_write or error({ "Error: Could not save file.", err })
end

function util.save_all()
	local write = function()
		vim.cmd("wall")
	end

	local try_write, err = pcall(write)
	return try_write or error({ "Error: Could not save file.", err })
end

return util
