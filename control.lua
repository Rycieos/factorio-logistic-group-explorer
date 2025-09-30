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

local function is_interface_valid(player_index)
  local guis = storage.guis[player_index]
  return guis and guis.main and guis.main.valid
end

local function destroy_interface(player_index)
  local guis = storage.guis[player_index]
  if is_interface_valid(player_index) then
    guis.main.destroy()
  end
  storage.guis[player_index] = nil
end

local function build_interface(player)
  destroy_interface(player.index)

  local main_frame = player.gui.left.add({
    type = "flow",
    name = main_frame_id,
    style = "packed_horizontal_flow",
  })
  main_frame.style.natural_height = 1160 / player.display_scale
  main_frame.style.maximal_height = main_frame.style.natural_height

  player.opened = main_frame
  local guis = { main = main_frame }
  storage.guis[player.index] = guis

  local groups_frame = main_frame.add({
    type = "frame",
    name = "groups_frame",
    direction = "vertical",
    style = "right_side_frame",
    caption = {
      "logistic_group_explorer-name.logistic-groups",
    },
  })
  groups_frame.style.natural_height = main_frame.style.natural_height
  groups_frame.style.vertically_stretchable = true

  guis.groups_list = groups_frame.add({
    type = "list-box",
    name = "groups_list",
    direction = "vertical",
    items = player.force.get_logistic_groups(),
  })
  guis.groups_list.selected_index = 1
  guis.groups_list.style.vertically_stretchable = true

  local combo_frame =
    main_frame.add({ type = "frame", name = "combo_frame", direction = "vertical", style = "right_side_frame" })
  combo_frame.style.minimal_width = 40 * 6 + 12 + 16
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
  members_frame.style.maximal_height = main_frame.style.maximal_height / 2

  local members_header = members_frame.add({
    type = "frame",
    name = "members_header",
    style = "lge__subheader_frame_no_filler",
    caption = { "gui-logistic.members" },
  })

  local members_scroll_pane = members_frame.add({
    type = "scroll-pane",
    name = "members_scroll_pane",
    direction = "vertical",
    style = "logistic_gui_items_scroll_pane",
    horizontal_scroll_policy = "never",
    vertical_scroll_policy = "always",
  })

  guis.members_table = members_scroll_pane.add({
    type = "table",
    name = "members_table",
    style = "slot_table",
    column_count = 6,
    vertical_centering = false,
  })

  local filters_frame =
    combo_flow.add({ type = "frame", name = "filters_frame", direction = "vertical", style = "inside_deep_frame" })
  filters_frame.style.vertically_stretchable = true

  filters_frame.add({
    type = "frame",
    name = "filters_header",
    style = "lge__subheader_frame_no_filler",
    caption = { "description.logistic-chest-filters" },
  })
  local filters_scroll_pane = filters_frame.add({
    type = "scroll-pane",
    name = "filters_scroll_pane",
    direction = "vertical",
    style = "logistic_gui_items_scroll_pane",
    horizontal_scroll_policy = "never",
    vertical_scroll_policy = "always",
  })
  filters_scroll_pane.style.vertically_stretchable = true

  guis.filters_table = filters_scroll_pane.add({
    type = "table",
    name = "filters_table",
    style = "slot_table",
    column_count = 6,
    vertical_centering = false,
  })

  populate_logistic_group(player)
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

script.on_event(defines.events.on_player_display_scale_changed, function(event)
  if is_interface_valid(event.player_index) then
    local player = game.get_player(event.player_index)
    destroy_interface(player.index)
    build_interface(player)
  end
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  if event.element and event.element.name == "groups_list" then
    local player = game.get_player(event.player_index)
    if is_interface_valid(event.player_index) then
      populate_logistic_group(player)
    end
  end
end)
