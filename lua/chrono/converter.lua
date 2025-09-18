-- lua/chrono/converter.lua
-- Pure timestamp conversion logic
local M = {}

local min_epoch = 0          -- Jan 1, 1970
local max_epoch = 4102444800 -- Jan 1, 2100

local function check_validation_and_get_number_lenght(number_selected, selected)
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

function M.convert_timestamp(selected, date_format)
  date_format = date_format or '%Y-%m-%d %H:%M:%S'

  -- Convert to human readable time
  local number_selected = tonumber(selected)

  --  Check if selected text is valid
  local success, result = pcall(function()
    return check_validation_and_get_number_lenght(number_selected, selected)
  end)

  if not success then
    return clean_error(result)
  end

  local number_length = result -- This is the returned value

  -- Timestamp diving logic
  local is_handled, handle_number_result = pcall(function()
    return handle_number(number_length, number_selected)
  end)

  if not is_handled then
    return clean_error(handle_number_result)
  end

  -- convert validated timestamp
  local converted = os.date(date_format, handle_number_result)

  return converted
end

return M