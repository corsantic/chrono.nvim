# chrono.nvim

Convert epoch timestamps to human-readable time in Neovim.

## Installation

```lua
-- Using lazy.nvim
{
  'corsantic/chrono.nvim',
  config = function()
    require('chrono').setup()
  end
}
```

## Usage

1. Select an epoch timestamp in visual mode
2. Press `<leader>ec` to convert it
3. The converted time appears in a floating window
4. Press `Esc` or `q` to close the window

## Supported formats

- Seconds: `1640995200`
- Milliseconds: `1640995200000`
- Microseconds: `1640995200000000`

## Configuration

```lua
require('chrono').setup({
  enabled = true,                    -- Enable/disable the plugin
  convert_key = '<leader>ec',        -- Key mapping for conversion
  date_format = '%Y-%m-%d %H:%M:%S'  -- Date format (Default: '%Y-%m-%d %H:%M:%S')
})
```

## Commands

- `:lua require('chrono').enable()` - Enable chrono
- `:lua require('chrono').disable()` - Disable chrono
- `:lua require('chrono').toggle()` - Toggle chrono on/off
