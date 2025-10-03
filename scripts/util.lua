util = {}

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

-- The core/lualib/util.lua function does not match what the circuit and
-- logistic systems do.
-- Factorio does not support localized number separators.
-- Always display negative sign.
-- Always display unit if above 999, truncating.
-- Always display 2 digits if truncated number above 99, otherwise 3.
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
    amount = string.format("%." .. (math.abs(amount) < 10.0 and 1 or 0) .. "f", amount)
  end
  return amount .. suffix
end

return util
