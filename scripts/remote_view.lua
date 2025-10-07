local player_data = require("scripts.player_data")

local remote_view = {}

-- Enter the remote view controller for the player, disabling the surface list
-- window to make room for the main frame.
---@param player LuaPlayer
function remote_view.enter(player)
  player_data(player.index).player_view = {
    show_surface_list = player.game_view_settings.show_surface_list,
    controller = player.controller_type,
    exit_remote_view = true,
  }

  -- Hide SurfaceList from RemoteView.
  player.game_view_settings.show_surface_list = false

  if player.controller_type ~= defines.controllers.remote then
    player.set_controller({
      type = defines.controllers.remote,
    })
  end
end

-- Exit remote view, restoring the controller that existed before we entered
-- remote view. Do not exit if requested not to with
-- player_data.player_view.exit_remote_view = false, used when opening an entity
-- GUI as remote view is required to not have the GUI close immediately.
---@param player LuaPlayer
function remote_view.exit(player)
  local player_view = player_data(player.index).player_view

  player.game_view_settings.show_surface_list = player_view.show_surface_list

  if not player_view.exit_remote_view then
    return
  end

  local controller_type = player_view.controller
  -- Cutscene requires data that we do not have, so we can't restore it.
  if
    controller_type
    and controller_type ~= defines.controllers.remote
    and controller_type ~= defines.controllers.cutscene
    and (controller_type ~= defines.controllers.character or (player.character and player.character.valid))
  then
    player.set_controller({
      type = controller_type,
      character = player.character,
    })
  end
end

return remote_view
