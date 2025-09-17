-- lua/Chrono.lua
-- Epoch converter to Human Readable Time for Neovim
local M = {}
local api = vim.api

-- Configuration
M.config = {
  enabled = true,
  convert_key = '<leader>ec',
}


local function create_window()
  start_win = api.nvim_get_current_win()

  api.nvim_command('botright vnew')
  win = api.nvim_get_current_win()
  buf = api.nvim_get_current_buf()

  api.nvim_buf_set_name(buf, "Epoch " .. buf)


  -- prevent the buffer from being saved
  api.nvim_set_option_value('buftype', 'nofile', { scope = 'local', buf = buf })
  -- if hidden wipe the buffer
  api.nvim_set_option_value('bufhidden', 'wipe', { scope = 'local', buf = buf })
  -- we do not need swapfile for this
  api.nvim_set_option_value('swapfile', false, { scope = 'local', buf = buf })
  -- we do not want our file overlap with other filetypes
  api.nvim_set_option_value('filetype', 'nvim-chrono', { scope = 'local', buf = buf })


  api.nvim_set_option_value('wrap', false, { scope = 'local', win = win })
  api.nvim_set_option_value('cursorline', true, { scope = 'local', win = win })
end

local function redraw(converted_time)
  if buf == nil or win == nil or not api.nvim_buf_is_valid(buf) or not api.nvim_win_is_valid(win) then
    create_window()
  end
  api.nvim_buf_set_lines(buf, 0, -1, false, { converted_time })
end


local function text_validation(number_selected, selected)
  if (number_selected == nil) then
    error("Selected text is not a valid number")
  end

  local number_length = string.len(selected)
  if (number_selected < 0) then
    error("Negative numbers are not supported")
  end

  if (number_length < 10) then
    error("Numbers less than 10 cannot be converted")
  end
  return number_length
end


local function handle_number(number_length, number_selected)
  if (number_length >= 16) then
    number_selected = number_selected / 1000000
  elseif (number_length >= 13) then
    number_selected = number_selected / 1000
  end
  return number_selected
end


function M._convert_to_hrt()
  if not M.config or not M.config.enabled then
    return
  end

  -- Get visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_row, start_col = start_pos[2], start_pos[3]
  local end_row, end_col = end_pos[2], end_pos[3]

  local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  local selected
  if #lines ~= 1 then
    return
  end

  selected = string.sub(lines[1], start_col, end_col)

  -- Convert to human readable time
  local number_selected = tonumber(selected)
  --  Check if selected text is valid

  local success, result = pcall(text_validation,
    number_selected, selected)

  if not success then
    print(result) -- This is the error message
    redraw(result)
    return
  end

  local number_length = result -- This is the returned value

  -- Timestamp diving logic
  number_selected = handle_number(number_length, number_selected)

  local converted = os.date("%c", number_selected)

  print(converted)
  redraw(converted)
end

local function generate_handle_key()
  vim.keymap.set({ "n", "v" }, M.config.convert_key, function()
    M._convert_to_hrt()
  end)
end

-- Initialize Chrono
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)
  generate_handle_key()
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
