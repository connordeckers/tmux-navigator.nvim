---Tmux Config
---@class TmuxIntegrationConfig
---@field enabled boolean Whether to enable or disable this integration
---@field SaveOnSwitch 'never' | 'single' | 'all' Whether to save the current/all buffers when switching.
---@field DisableWhenZoomed boolean Whether to allow movement between tmux panes when zoomed in
---@field PreserveZoom boolean Whether to stay zoomed in, or unzoom when switching panes
---@field NoWrap boolean Whether to wrap around tmux panes, or stick to the edge
---@field DisableMapping boolean Whether to allow default mappings, or recreate manually

--- Default config options
---@private
---@class TmuxRootConfig
---@field config TmuxIntegrationConfig
local Config = {
  state = {},
  config = {
    enabled = true,
    SaveOnSwitch = 'never',
    DisableWhenZoomed = false,
    PreserveZoom = false,
    NoWrap = false,
    DisableMapping = false,
  },
}

---@private
---Updates the default config
---@param cfg? TmuxIntegrationConfig
---@return TmuxRootConfig
---@usage `require('tmux.config'):set(config)`
function Config:set(cfg)
  if cfg then
    self.config = vim.tbl_deep_extend('force', self.config, cfg)
  end
  return self
end

---Get the config
---@return TmuxIntegrationConfig
---@usage `require('tmux.config'):get()`
function Config:get()
  return self.config
end

---@export Config
return setmetatable(Config, {
  __index = function(this, k)
    return this.state[k]
  end,

  __newindex = function(this, k, v)
    this.state[k] = v
  end,
})
