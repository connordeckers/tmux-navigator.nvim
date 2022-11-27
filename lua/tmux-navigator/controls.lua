local notify = require("notify").notify
local util = require("tmux-navigator.utils")
local config = require("tmux-navigator.config")

local Tmux = {
	WasLastPane = false,
}

-- Determine if the current tmux pane is zoomed in.
function Tmux.IsZoomed()
	local output = util.exec("display-message -p '#{window_zoomed_flag}'")
	return output == "1"
end

-- Show the processes running within the current tmux instance
function Tmux.ProcessList()
	local output = util.exec("run-shell 'ps -o state= -o comm= -t ''''#{pane_tty}'''''")
	return output
end

function SendMovementToTmux(IsLastPane, AtTabPageEdge)
	local cfg = config:get()
	if Tmux.IsZoomed() and cfg.DisableWhenZoomed then
		return false
	end

	return IsLastPane or AtTabPageEdge or false
end

-- Navigate with self-aware capability between tmux/vim panes
---@param direction "h" | "j" | "k" | "l" | "p"
function Tmux.SelfAwareNavigate(direction)
	---@type TmuxIntegrationConfig
	local cfg = config:get()
	local winnr = vim.fn.winnr()

	local UseTmuxLastPane = direction == "p" and Tmux.WasLastPane

	if not UseTmuxLastPane then
		util.navigate.nvim[direction]()
	end

	-- Whether we moved or not
	local AtEdge = winnr == vim.fn.winnr()

	-- Whether or not this is going to be sent to tmux or stay inside neovim.
	local ShouldSendMovement = SendMovementToTmux(Tmux.WasLastPane, AtEdge)

	if ShouldSendMovement then
		if cfg.SaveOnSwitch == "single" then
			util.save_one()
		elseif cfg.SaveOnSwitch == "all" then
			util.save_all()
		end

		local pane = vim.fn.shellescape(os.getenv("TMUX_PANE"))
		local dir = util.vim_direction_to_select_pane_direction(direction)

		local args = {
			"select-pane",
			"-t",
			pane,
			" -" .. dir,
		}

		if cfg.PreserveZoom then
			table.insert(args, "-Z")
		end

		local argstr = table.concat(args, " ")

		if cfg.NoWrap then
			argstr = 'if -F "#{pane_at_' .. util.pane_position_from_direction(direction) .. '}" "" "' .. argstr .. '"'
		end

		util.exec(argstr)
	end

	Tmux.WasLastPane = ShouldSendMovement
end

Tmux.navigate = {
	-- Navigate to the left pane of either neovim or tmux
	left = function()
		Tmux.SelfAwareNavigate("h")
	end,

	-- Navigate to the below pane of either neovim or tmux
	down = function()
		Tmux.SelfAwareNavigate("j")
	end,

	-- Navigate to the above pane of either neovim or tmux
	up = function()
		Tmux.SelfAwareNavigate("k")
	end,

	-- Navigate to the right pane of either neovim or tmux
	right = function()
		Tmux.SelfAwareNavigate("l")
	end,

	-- Navigate to the previous pane of either neovim or tmux
	previous = function()
		Tmux.SelfAwareNavigate("p")
	end,
}

return Tmux
