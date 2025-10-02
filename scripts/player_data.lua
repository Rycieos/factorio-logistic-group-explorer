local function player_data(player_index)
  if not storage.player_data[player_index] then
    storage.player_data[player_index] = {
      player_view = {},
      guis = {},
      entities = {},
      last_group = nil,
    }
  end
  return storage.player_data[player_index]
end

return player_data
