const = require("const")
groups = require("scripts.logistic_groups")
search = require("scripts.search")
entity_view = require("scripts.entity_view")
player_data = require("scripts.player_data")
main_gui = require("scripts.main_gui")

script.on_init(function()
  storage.player_data = {}
end)

local function is_event_valid(event)
  return event.element and main_gui.valid(event.player_index)
end

local function toggle(event)
  local player = game.get_player(event.player_index)
  main_gui.toggle(player)
end

script.on_event(const.toggle_interface_id, toggle)

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name == const.toggle_interface_shortcut then
    toggle(event)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if is_event_valid(event) and event.element.name == const.main_frame_id then
    toggle(event)
  end
end)

script.on_configuration_changed(function(config_changed_data)
  if config_changed_data.mod_changes[const.mod_name] then
    if storage.player_data then
      for index, _ in pairs(storage.player_data) do
        main_gui.destroy(index)
      end
    end
    storage.player_data = {}
  end
end)

script.on_event(defines.events.on_player_display_scale_changed, function(event)
  if main_gui.valid(event.player_index) then
    local player = game.get_player(event.player_index)
    main_gui.build(player)
  end
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  local guis = player_data(event.player_index).guis
  if is_event_valid(event) and event.element == guis.groups_list then
    local player = game.get_player(event.player_index)
    groups.populate_logistic_group(player)
    search.update_search_results(guis, player)
  end
end)

local function toggle_search_box(guis)
  -- Poor man's overlay textbox.
  if guis.search_box.visible then
    guis.search_box.visible = false
    guis.search_box.text = ""
    -- The above line does not trigger an event.
    -- No need to pass a player as no query means no translation requests.
    search.update_search_results(guis, nil)
    guis.search_button.toggled = false
    guis.group_delete_button.visible = true
    guis.group_label.style.maximal_width = guis.group_label.style.maximal_width + (104 - 24)
  else
    guis.search_box.visible = true
    guis.search_box.focus()
    guis.search_button.toggled = true
    guis.group_delete_button.visible = false
    guis.group_label.style.maximal_width = guis.group_label.style.maximal_width - (104 - 24)
  end
end

script.on_event(defines.events.on_gui_click, function(event)
  if not is_event_valid(event) then
    return
  end
  local guis = player_data(event.player_index).guis
  local player = game.get_player(event.player_index)
  if event.element.parent == guis.members_table then
    entity_view.jump(player, event.element.tags)
  elseif event.element == guis.group_delete_button then
    local group_name = guis.groups_list.get_item(guis.groups_list.selected_index)
    player.force.delete_logistic_group(group_name)
    main_gui.build(player)
  elseif event.element == guis.search_button then
    toggle_search_box(guis)
  end
end)

script.on_event(const.focus_search_id, function(event)
  if main_gui.valid(event.player_index) then
    local guis = player_data(event.player_index).guis
    if guis.search_box.visible then
      guis.search_box.select_all()
    else
      toggle_search_box(guis)
    end
  end
end)

script.on_event(defines.events.on_string_translated, function(event)
  if event.translated and main_gui.valid(event.player_index) then
    local guis = player_data(event.player_index).guis
    search.update_string_translation(guis, event)
  end
end)

script.on_event({ defines.events.on_gui_hover, defines.events.on_gui_leave }, function(event)
  if not is_event_valid(event) then
    return
  end
  local guis = player_data(event.player_index).guis
  if event.element.parent == guis.members_table then
    if event.name == defines.events.on_gui_hover then
      entity_view.build(event.player_index, event.element.tags)
    else
      entity_view.destroy(event.player_index)
    end
  end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  if not is_event_valid(event) then
    return
  end
  local guis = player_data(event.player_index).guis
  if event.element == guis.search_box then
    local player = game.get_player(event.player_index)
    search.update_search_results(guis, player)
  end
end)

script.on_event(defines.events.on_entity_logistic_slot_changed, function(event)
  local group = event.section.group
  if not event.section.is_manual or group == "" then
    return
  end

  local players = event.entity.force.connected_players
  for _, player in pairs(players) do
    if player_data(player.index).last_group == group and main_gui.valid(player.index) then
      groups.populate_logistic_group(player)
    end
  end
end)
