-- lua/chrono/helper.lua
-- Helper functions

local M = {}


function M.clean_error(result)
  return result:match("assertion failed!%s*(.*)") or result:match(":%d+:%s*(.*)") or result
end


return M
