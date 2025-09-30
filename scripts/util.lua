util = {}

function util.find(table, element)
  for index, value in ipairs(table) do
    if value == element then
      return index
    end
  end
  return 0
end

return util
