---@class PlayerView
---@field show_surface_list? boolean
---@field controller? defines.controllers
---@field exit_remote_view? boolean

---@alias Guis { [string]: LuaGuiElement }

---@class PlayerData
---@field player_view PlayerView
---@field guis Guis
---@field entities LuaEntity[]
---@field last_group? string

-- Get the PlayerData storage table for the specified player.
---@param player_index uint32
---@return PlayerData
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
