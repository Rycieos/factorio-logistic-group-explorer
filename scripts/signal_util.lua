signal_util = {}

-- Input for all functions:
-- https://lua-api.factorio.com/stable/concepts/SignalFilter.html
--
-- type: SignalIDType :: union
-- Union members
-- "item"
-- "fluid"
-- "virtual"
-- "entity"
-- "recipe"
-- "space-location"
-- "asteroid-chunk"
-- "quality"

-- https://lua-api.factorio.com/stable/concepts/ElemID.html
--
-- type: ElemType :: union
-- Union members
-- "achievement"
-- "decorative"
-- "entity"
-- "equipment"
-- "fluid"
-- "item"
-- "item-group"
-- "recipe"
-- "signal"
-- "technology"
-- "tile"
-- "asteroid-chunk"
-- "space-location"
-- "item-with-quality"
-- "entity-with-quality"
-- "recipe-with-quality"
-- "equipment-with-quality"
--
-- signal_type: SignalIDType
function signal_util.to_elem_id(filter)
  local signal_type = filter.type
  if signal_type == "virtual" then
    signal_type = "signal"
  elseif signal_type == "item" then
    signal_type = "item-with-quality"
  elseif signal_type == "entity" then
    signal_type = "entity-with-quality"
  elseif signal_type == "recipe" then
    signal_type = "recipe-with-quality"
  end
  return {
    type = signal_type,
    signal_type = signal_type == "signal" and filter.type or nil,
    name = filter.name,
    quality = filter.quality,
  }
end

-- https://lua-api.factorio.com/stable/concepts/SpritePath.html
-- Union members
-- "item"
-- "entity"
-- "technology"
-- "recipe"
-- "fluid"
-- "tile"
-- "item-group"
-- "virtual-signal"
-- "shortcut"
-- "achievement"
-- "equipment"
-- "ammo-category"
-- "decorative"
-- "space-connection"
-- "space-location"
-- "surface"
-- "airborne-pollutant"
-- "asteroid-chunk"
-- "quality"
-- "file"
-- "utility"
function signal_util.to_sprite_path(filter)
  local signal_type = filter.type
  if signal_type == "virtual" then
    signal_type = "virtual-signal"
  end
  return signal_type .. "/" .. filter.name
end

-- https://lua-api.factorio.com/stable/classes/LuaPrototypes.html
--
-- key :: union
-- Union members
-- "item"
-- "fluid"
-- "virtual_signal"
-- "entity"
-- "recipe"
-- "space_location"
-- "asteroid_chunk"
-- "quality"
function signal_util.to_prototype(filter)
  local signal_type = filter.type
  if signal_type == "virtual" then
    signal_type = "virtual_signal"
  elseif signal_type == "space-location" then
    signal_type = "space_location"
  elseif signal_type == "asteroid-chunk" then
    signal_type = "asteroid_chunk"
  end
  return prototypes[signal_type][filter.name]
end

return signal_util
