# tmux-navigator.nvim

### Inspired by github.com/christoomey/vim-tmux-navigator

Allows for seamless navigation between Tmux and Neovim, using the same keybinds wherever possible.

## Default config

```lua
{
    -- enabled | boolean
    -- Whether to enable or disable this integration
    enabled = true,

    -- SaveOnSwitch | 'never' | 'single' | 'all'
    -- Whether to save the current/all buffers when switching.
    SaveOnSwitch = 'never',

    -- DisableWhenZoomed | boolean
    -- Whether to allow movement between tmux panes when zoomed in
    DisableWhenZoomed = false,

    -- PreserveZoom | boolean
    -- Whether to stay zoomed in, or unzoom when switching panes
    PreserveZoom = false,

    -- NoWrap | boolean
    -- Whether to wrap around tmux panes, or stick to the edge
    NoWrap = false,

    -- DisableMapping | boolean
    -- Whether to allow default mappings, or recreate manually
    DisableMapping = false,
}

```

## Default mapping

```lua
local keymap_opts = { noremap = true, silent = true }
local keymap = {
    ["<C-h>"] = tmux.navigate.left, -- Move left
    ["<C-j>"] = tmux.navigate.down, -- Move down
    ["<C-k>"] = tmux.navigate.up, -- Move up
    ["<C-l>"] = tmux.navigate.right, -- Move right
    ["<C-p>"] = tmux.navigate.previous, -- Move to previously focused pane
}
```

## Example usage

### packer.nvim

```lua
  use {
    'connordeckers/tmux-navigator.nvim',
    config = function()
      require('tmux-navigator').setup { enable = true }
    end,
  }
```
