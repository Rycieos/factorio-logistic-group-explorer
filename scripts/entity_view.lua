player_data = require("scripts.player_data")

entity_view = {}

function entity_view.destroy(player_index)
  local guis = player_data(player_index).guis
  if guis.entity_preview and guis.entity_preview.valid then
    guis.entity_preview.destroy()
  end
end

function entity_view.build(player_index, entity_data)
  entity_view.destroy(player_index)

  local data = player_data(player_index)
  local guis = data.guis

  guis.entity_preview = guis.main.add({
    type = "frame",
    name = "entity_preview_frame",
  })
  local preview = guis.entity_preview.add({
    type = "camera",
    surface_index = entity_data.surface,
    position = entity_data.position,
    zoom = 1.5,
  })
  preview.style.size = math.min(500, guis.main.style.natural_height - 20)

  -- If we can locate the actual entity, tell the game to follow it.
  local entity = data.entities[entity_data.entity_index]
  if entity and entity.valid then
    preview.entity = entity
  end
end

function entity_view.jump(player, entity_data)
  local data = player_data(player.index)
  player.set_controller({
    type = defines.controllers.remote,
    surface = entity_data.surface,
    position = entity_data.position,
  })

  local entity = data.entities[entity_data.entity_index]
  if entity and entity.valid and entity.operable and entity.type ~= "character" then
    data.player_view.exit_remote_view = false
    player.opened = entity
  else
    -- Close camera so we can see what we jumped to.
    entity_view.destroy(player.index)
  end
end

return entity_view
