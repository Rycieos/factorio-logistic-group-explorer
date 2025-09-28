require("const")
require("scripts.logistic_groups")

local function init()
  storage.player_view = {}
  storage.guis = {}
end

local function enter_remote_view(player)
  storage.player_view[player.index] = {
    show_surface_list = player.game_view_settings.show_surface_list,
    controller = player.controller_type,
    character = player.character,
  }

  -- Hide SurfaceList from RemoteView.
  player.game_view_settings.show_surface_list = false

  if player.controller_type ~= defines.controllers.remote then
    player.set_controller({
      type = defines.controllers.remote,
    })
  end
end

local function exit_remote_view(player)
  local player_view = storage.player_view[player.index]
  if not player_view then
    return
  end

  player.game_view_settings.show_surface_list = player_view.show_surface_list

  local controller_type = player_view.controller
  -- Cutscene requires data that we do not have, so we can't restore it.
  if
    controller_type
    and controller_type ~= defines.controllers.remote
    and controller_type ~= defines.controllers.cutscene
  then
    player.set_controller({
      type = controller_type,
      character = player_view.character,
    })
  end

  storage.player_view[player.index] = nil
end

local function build_interface(player)
  local main_frame = player.gui.left.add({
    type = "flow",
    name = main_frame_id,
    style = "packed_horizontal_flow",
  })

  player.opened = main_frame
  local guis = { main = main_frame }
  storage.guis[player.index] = guis

  local groups_frame =
    main_frame.add({ type = "frame", name = "groups_frame", direction = "vertical", style = "right_side_frame" })
  groups_frame.add({
    type = "label",
    name = "menu_header",
    style = "frame_title",
    caption = {
      "logistic_group_explorer-name.logistic-groups",
    },
  })
  local groups_list = groups_frame.add({
    type = "list-box",
    name = "groups_list",
    direction = "vertical",
    items = player.force.get_logistic_groups(),
  })
  groups_list.selected_index = 1

  local combo_frame =
    main_frame.add({ type = "frame", name = "combo_frame", direction = "vertical", style = "right_side_frame" })
  local group_header = combo_frame.add({ type = "flow", name = "group_header", style = "frame_header_flow" })
  guis.group_label = group_header.add({ type = "label", name = "group_label", style = "frame_title" })
  local combo_flow = combo_frame.add({
    type = "flow",
    name = "combo_flow",
    direction = "vertical",
    style = "inset_frame_container_vertical_flow",
  })

  local members_frame =
    combo_flow.add({ type = "frame", name = "members_frame", direction = "vertical", style = "inside_deep_frame" })
  members_frame.add({
    type = "label",
    name = "members_header",
    style = "subheader_caption_label",
    caption = { "gui-logistic.members" },
  })
  guis.members_table = members_frame.add({
    type = "table",
    name = "members_table",
    style = "slot_table",
    column_count = 6,
    draw_horizontal_lines = true,
    draw_vertical_lines = true,
    vertical_centering = false,
  })

  local contents_frame =
    combo_flow.add({ type = "frame", name = "contents_frame", direction = "vertical", style = "inside_deep_frame" })
  contents_frame.add({
    type = "label",
    name = "contents_header",
    style = "subheader_caption_label",
    caption = { "description.logistic-chest-filters" },
  })
  guis.contents_table = contents_frame.add({
    type = "table",
    style = "slot_table",
    column_count = 6,
    draw_horizontal_lines = true,
    draw_vertical_lines = true,
    vertical_centering = false,
  })

  populate_logistic_group(player, groups_list.get_item(1))
end

local function destroy_interface(player_index)
  local frame = storage.guis[player_index]
  if frame == nil then
    return
  end
  if frame.valid then
    frame.destroy()
  end
  storage.guis[player_index] = nil
end

local function toggle_interface(player)
  if not storage.player_view or not storage.guis then
    init()
  end

  if storage.guis[player.index] == nil then
    enter_remote_view(player)
    build_interface(player)
  else
    destroy_interface(player.index)
    exit_remote_view(player)
  end
end

script.on_event(toggle_interface_id, function(event)
  local player = game.get_player(event.player_index)
  toggle_interface(player)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == main_frame_id then
    local player = game.get_player(event.player_index)
    toggle_interface(player)
  end
end)

script.on_configuration_changed(function(config_changed_data)
  if config_changed_data.mod_changes[mod_name] then
    if storage.guis then
      for index, _ in pairs(storage.guis) do
        destroy_interface(index)
      end
    end
    init()
  end
end)

script.on_init(init)
