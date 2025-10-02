const = require("const")
util = require("scripts.util")
groups = require("scripts.logistic_groups")
search = require("scripts.search")

local function init()
  storage.player_view = {}
  storage.guis = {}
  storage.last_group = {}
  storage.entities = {}
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
  if not player_view or player_view.stay_in_remote_view then
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
    name = const.main_frame_id,
    style = "packed_horizontal_flow",
  })
  main_frame.style.natural_height = 800 / player.display_scale
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

  local logistic_groups = player.force.get_logistic_groups()
  guis.groups_list = groups_frame.add({
    type = "list-box",
    name = "groups_list",
    direction = "vertical",
    items = logistic_groups,
  })
  guis.groups_list.style.vertically_stretchable = true

  if #logistic_groups == 0 then
    guis.groups_list.selected_index = 0
    local no_groups_message = guis.groups_list.add({
      type = "frame",
      name = "no_groups_message",
      style = "negative_subheader_frame",
      caption = { "", "[img=utility/warning_white] ", { "logistic_group_explorer-name.no-logistic-groups" } },
    })
    -- This element does not want to horizontally stretch.
    -- This width is the width of the right_side_frame.
    no_groups_message.style.natural_width = const.slot_size * 6
    return
  end

  guis.groups_list.selected_index = 1
  if storage.last_group and storage.last_group[player.index] then
    local last_group_index = util.find(logistic_groups, storage.last_group[player.index])
    if last_group_index > 0 then
      guis.groups_list.selected_index = last_group_index
    end
  end

  local combo_frame = main_frame.add({
    type = "frame",
    name = "combo_frame",
    direction = "vertical",
    style = "lge__right_side_frame_no_spacer",
  })
  combo_frame.style.minimal_width = const.slot_size * const.slot_count + 12 + 16

  local group_header = combo_frame.add({ type = "flow", name = "group_header", style = "frame_header_flow" })
  guis.group_label = group_header.add({ type = "label", name = "group_label", style = "frame_title" })
  guis.group_label.style.maximal_width = combo_frame.style.minimal_width - 8 - (24 + 16) * 2

  local group_spacer = group_header.add({ type = "empty-widget", style = "empty_widget" })
  group_spacer.style.horizontally_stretchable = true

  guis.group_delete_button = group_header.add({
    type = "sprite-button",
    name = "group_delete_button",
    style = "tool_button_red",
    sprite = "utility/trash",
    tooltip = { "gui-logistic.delete-logistic-group" },
  })
  guis.group_delete_button.style.size = 24

  guis.search_box = group_header.add({
    type = "textfield",
    name = "search_box",
    style = "search_popup_textfield",
    visible = false,
  })
  guis.search_button = group_header.add({
    type = "sprite-button",
    name = "search_button",
    style = "frame_action_button",
    sprite = "utility/search",
    tooltip = { "gui.search-with-focus", "__CONTROL__focus-search__" },
  })

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
    style = "lge__logistic_items_scroll_pane",
    horizontal_scroll_policy = "never",
    vertical_scroll_policy = "always",
  })

  guis.members_table = members_scroll_pane.add({
    type = "table",
    name = "members_table",
    style = "slot_table",
    column_count = const.slot_count,
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
    style = "lge__logistic_items_scroll_pane",
    horizontal_scroll_policy = "never",
    vertical_scroll_policy = "always",
  })
  filters_scroll_pane.style.vertically_stretchable = true

  guis.filters_table = filters_scroll_pane.add({
    type = "table",
    name = "filters_table",
    style = "slot_table",
    column_count = const.slot_count,
    vertical_centering = false,
  })

  groups.populate_logistic_group(player)
end

local function toggle_interface(player)
  if not storage.player_view or not storage.guis or not storage.last_group or not storage.entities then
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

local function is_event_valid(event)
  return event.element and is_interface_valid(event.player_index)
end

script.on_event(const.toggle_interface_id, function(event)
  local player = game.get_player(event.player_index)
  toggle_interface(player)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if is_event_valid(event) and event.element.name == const.main_frame_id then
    local player = game.get_player(event.player_index)
    toggle_interface(player)
  end
end)

script.on_configuration_changed(function(config_changed_data)
  if config_changed_data.mod_changes[const.mod_name] then
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
  if is_event_valid(event) then
    local player = game.get_player(event.player_index)
    destroy_interface(player.index)
    build_interface(player)
  end
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  if is_event_valid(event) and event.element.name == "groups_list" then
    local player = game.get_player(event.player_index)
    if is_interface_valid(event.player_index) then
      groups.populate_logistic_group(player)
      search.update_search_results(event.player_index)
    end
  end
end)

local function toggle_search_box(event)
  local guis = storage.guis[event.player_index]
  -- Poor man's overlay textbox.
  if guis.search_box.visible then
    guis.search_box.visible = false
    guis.search_box.text = ""
    search.update_search_results(event.player_index)
    guis.group_delete_button.visible = true
    guis.group_label.style.maximal_width = guis.group_label.style.maximal_width + (104 - 24)
  else
    guis.search_box.visible = true
    guis.search_box.focus()
    guis.group_delete_button.visible = false
    guis.group_label.style.maximal_width = guis.group_label.style.maximal_width - (104 - 24)
  end
end

script.on_event(defines.events.on_gui_click, function(event)
  if not is_event_valid(event) then
    return
  end
  local guis = storage.guis[event.player_index]
  local player = game.get_player(event.player_index)
  if event.element.parent == guis.members_table then
    player.set_controller({
      type = defines.controllers.remote,
      surface = event.element.tags.surface,
      position = event.element.tags.position,
    })
    local entity = storage.entities[event.player_index][event.element.tags.entity_index]
    if entity and entity.valid and entity.operable and entity.type ~= "character" then
      storage.player_view[event.player_index].stay_in_remote_view = true
      player.opened = entity
    else
      -- Close camera
      if guis.entity_preview and guis.entity_preview.valid then
        guis.entity_preview.destroy()
      end
    end
  elseif event.element == guis.group_delete_button then
    local group_name = guis.groups_list.get_item(guis.groups_list.selected_index)
    player.force.delete_logistic_group(group_name)
    storage.last_group[event.player_index] = nil
    build_interface(player)
  elseif event.element == guis.search_button then
    toggle_search_box(event)
  end
end)

script.on_event(const.focus_search_id, function(event)
  if is_interface_valid(event.player_index) then
    toggle_search_box(event)
  end
end)

script.on_event(defines.events.on_gui_hover, function(event)
  if not is_event_valid(event) then
    return
  end
  local guis = storage.guis[event.player_index]
  local player = game.get_player(event.player_index)
  local tags = event.element.tags
  if event.element.parent == guis.members_table then
    guis.entity_preview = guis.main.add({
      type = "frame",
      name = "entity_preview_frame",
    })
    local preview = guis.entity_preview.add({
      type = "camera",
      surface_index = tags.surface,
      position = tags.position,
      zoom = 1.5,
    })
    preview.style.size = 500

    -- If we can locate the actual entity, tell the game to follow it.
    local entity = storage.entities[event.player_index][tags.entity_index]
    if entity and entity.valid then
      preview.entity = entity
    end
  end
end)

script.on_event(defines.events.on_gui_leave, function(event)
  if not is_event_valid(event) then
    return
  end
  local guis = storage.guis[event.player_index]
  if event.element.parent == guis.members_table and guis.entity_preview and guis.entity_preview.valid then
    guis.entity_preview.destroy()
  end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  if not is_event_valid(event) then
    return
  end
  local guis = storage.guis[event.player_index]
  if event.element == guis.search_box then
    search.update_search_results(event.player_index)
  end
end)
