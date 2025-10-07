local util = {}

-- Find the index of an element in the table.
---@param table table
---@param element string
---@return uint32
function util.find(table, element)
  for index, value in pairs(table) do
    if value == element then
      return index
    end
  end
  return 0
end

local suffix_list = {
  G = 10 ^ 9,
  M = 10 ^ 6,
  k = 10 ^ 3,
}

-- Convert an integer into a magnitude unit-based string, to keep the string
-- size at 5 characters max.
--
-- The core/lualib/util.lua function does not match what the circuit and
-- logistic systems do.
-- Factorio does not support localized number separators.
-- Always display negative sign.
-- Always display unit if above 999, truncating.
-- Always display 2 digits if truncated number above 99, otherwise 3.
---@param amount int32
---@return string
function util.format_number(amount)
  local suffix = ""
  for letter, limit in pairs(suffix_list) do
    if math.abs(amount) >= limit then
      amount = amount / limit
      suffix = letter
      break
    end
  end
  if suffix ~= "" then
    return string.format("%." .. (math.abs(amount) < 10.0 and 1 or 0) .. "f", amount) .. suffix
  end
  return tostring(amount)
end

return util
