-- lua/chrono/ui.lua
-- UI for Chrono

local M = {}
local api = vim.api

local buf
local win

local function close_window()
  if win ~= nil and api.nvim_win_is_valid(win) then
    api.nvim_win_close(win, true)
  end
end
local function set_close_buffer_keymaps()
  -- Set buffer-specific keymaps right here
  vim.keymap.set("n", "<Esc>", close_window, { buffer = buf })
  vim.keymap.set("n", "q", close_window, { buffer = buf })
end

local function create_window()
  -- Create buffer
  buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_name(buf, "Epoch " .. buf)

  -- Get cursor position
  local cursor = api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  -- Create floating window at cursor position
  local opts = {
    relative = 'win',
    row = row,
    col = col + 1,
    width = 40,
    height = 1,
    style = 'minimal',
    border = 'rounded'
  }

  win = api.nvim_open_win(buf, true, opts)

  -- Buffer options
  api.nvim_set_option_value('buftype', 'nofile', { scope = 'local', buf = buf })
  api.nvim_set_option_value('bufhidden', 'wipe', { scope = 'local', buf = buf })
  api.nvim_set_option_value('swapfile', false, { scope = 'local', buf = buf })
  api.nvim_set_option_value('filetype', 'nvim-chrono', { scope = 'local', buf = buf })

  -- Window options
  api.nvim_set_option_value('wrap', false, { scope = 'local', win = win })
  api.nvim_set_option_value('cursorline', true, { scope = 'local', win = win })
  set_close_buffer_keymaps()
end

function M.redraw(converted_time)
  if buf == nil or win == nil or not api.nvim_buf_is_valid(buf) or not api.nvim_win_is_valid(win) then
    create_window()
  end
  ---@diagnostic disable-next-line: param-type-mismatch
  api.nvim_buf_set_lines(buf, 0, -1, false, { converted_time })
end

return M
