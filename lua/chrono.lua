-- lua/Chrono.lua
-- Epoch converter to Human Readable Time for Neovim
local M = {}
local api = vim.api

-- Configuration
M.config = {
  enabled = true,
  convert_key = '<leader>ec',
  date_format = '%Y-%m-%d %H:%M:%S'
}
local buf
local win

local min_epoch = 0          -- Jan 1, 1970
local max_epoch = 4102444800 -- Jan 1, 2100

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
end

local function redraw(converted_time)
  if buf == nil or win == nil or not api.nvim_buf_is_valid(buf) or not api.nvim_win_is_valid(win) then
    create_window()
  end
  api.nvim_buf_set_lines(buf, 0, -1, false, { converted_time })
end

local function close_window()
  if win ~= nil and api.nvim_win_is_valid(win) then
    api.nvim_win_close(win, true)
  end
end


local function number_lenght(number_selected, selected)
  assert(number_selected ~= nil, "Selected text is not a valid number")
  assert(number_selected >= 0, "Negative numbers are not supported")

  local number_length = string.len(selected)
  return number_length
end

local function handle_number(number_length, adjusted_time)
  -- Check if it's a reasonable timestamp (after 1970 and before year 2100)
  if (number_length >= 16) then
    adjusted_time = adjusted_time / 1000000 -- microseconds
  elseif (number_length >= 13) then
    adjusted_time = adjusted_time / 1000    -- millisecond
  end

  assert(adjusted_time >= min_epoch and adjusted_time <= max_epoch,
    "Number doesn't appear to be a valid timestamp")

  return adjusted_time
end


local function clean_error(result)
  return result:match("assertion failed!%s*(.*)") or result:match(":%d+:%s*(.*)") or result
end


function M._convert_to_hrt()
  if not M.config or not M.config.enabled then
    return
  end

  -- Exit visual mode and get selection
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_row, start_col = start_pos[2], start_pos[3]
  local end_row, end_col = end_pos[2], end_pos[3]

  local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  local selected
  if #lines ~= 1 then
    redraw("Multi-line selection not supported")
    return
  end

  selected = string.sub(lines[1], start_col, end_col)

  -- Convert to human readable time
  local number_selected = tonumber(selected)

  --  Check if selected text is valid
  local success, result = pcall(function()
    return number_lenght(number_selected, selected)
  end)

  if not success then
    redraw(clean_error(result))
    return
  end

  local number_length = result -- This is the returned value

  -- Timestamp diving logic
  local is_handled, handle_number_result = pcall(function()
    return handle_number(number_length, number_selected)
  end)

  if not is_handled then
    redraw(clean_error(handle_number_result))
    return
  end

  -- convert validated timestamp
  local converted = os.date(M.config.date_format, handle_number_result)

  -- draw result
  redraw(converted)
end

local function set_close_keys()
  vim.keymap.set("n", "<Esc>", function()
    close_window()
  end, { buffer = buf })
  vim.keymap.set("n", "q", function()
    close_window()
  end, { buffer = buf })
end


local function set_keymaps()
  vim.keymap.set("v", M.config.convert_key, function()
    M._convert_to_hrt()
  end)
  set_close_keys()
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
