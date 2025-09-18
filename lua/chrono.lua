-- lua/Chrono.lua
-- Epoch converter to Human Readable Time for Neovim
local M = {}
local api = vim.api
local converter = require('chrono.converter')
local ui = require('chrono.ui')

-- Configuration
M.config = {
  enabled = true,
  convert_key = '<leader>ec',
  date_format = '%Y-%m-%d %H:%M:%S'
}


local function get_selected_text()
  -- Exit visual mode and get selection
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_row, start_col = start_pos[2], start_pos[3]
  local end_row, end_col = end_pos[2], end_pos[3]

  local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  local selected
  if #lines ~= 1 then
    return ("Multi-line selection not supported")
  end

  selected = string.sub(lines[1], start_col, end_col)
  return selected
end


function M._convert_to_hrt()
  if not M.config or not M.config.enabled then
    return
  end
  local selected = get_selected_text()

  local converted_time = converter.convert_timestamp(selected, M.config.date_format)
  if converted_time then
    ui.redraw(converted_time)
  end
end

local function set_keymaps()
  vim.keymap.set("v", M.config.convert_key, function()
    M._convert_to_hrt()
  end)
end

-- Initialize Chrono
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)
  set_keymaps()
end

-- Toggle Chrono on/off
function M.toggle()
  M.config.enabled = not M.config.enabled
  local status = M.config.enabled and "enabled" or "disabled"
  print("Chrono " .. status)
end

-- Enable Chrono
function M.enable()
  M.config.enabled = true
  print("Chrono enabled")
end

-- Disable Chrono
function M.disable()
  M.config.enabled = false
  print("Chrono disabled")
end

return M
