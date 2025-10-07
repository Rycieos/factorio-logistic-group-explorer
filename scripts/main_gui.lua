local const = require("const")
local groups = require("scripts.logistic_groups")
local player_data = require("scripts.player_data")
local remote_view = require("scripts.remote_view")
local util = require("scripts.util")

local main_gui = {}

-- Return true if the player has a valid main frame open.
---@param player_index uint32
function main_gui.valid(player_index)
  local guis = player_data(player_index).guis
  return guis.main and guis.main.valid
end

-- Destroy the main frame if it exists.
---@param player_index uint32
function main_gui.destroy(player_index)
  local data = player_data(player_index)
  if main_gui.valid(player_index) then
    data.guis.main.destroy()
  end
  data.guis = {}
  data.entities = {}
end

-- Build a new main frame for the player.
---@param player LuaPlayer
function main_gui.build(player)
  main_gui.destroy(player.index)

  local main_frame = player.gui.left.add({
    type = "flow",
    name = const.main_frame_id,
    style = "packed_horizontal_flow",
  })
  main_frame.style.natural_height = 800 / player.display_scale
  main_frame.style.maximal_height = main_frame.style.natural_height

  player.opened = main_frame
  local guis = { main = main_frame }
  local data = player_data(player.index)
  data.guis = guis

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

  if table_size(logistic_groups) == 0 then
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
  local last_group = data.last_group
  if last_group then
    local last_group_index = util.find(logistic_groups, last_group)
    if last_group_index > 0 then
      guis.groups_list.selected_index = last_group_index
    end
  end

  local combo_frame = main_frame.add({
    type = "frame",
    name = "combo_frame",
    direction = "vertical",
    style = const.right_side_no_spacer_frame,
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
    style = const.subheader_no_filler_frame,
    caption = { "gui-logistic.members" },
  })

  local members_scroll_pane = members_frame.add({
    type = "scroll-pane",
    name = "members_scroll_pane",
    direction = "vertical",
    style = const.logistic_items_scroll_pane,
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
    style = const.subheader_no_filler_frame,
    caption = { "description.logistic-chest-filters" },
  })
  local filters_scroll_pane = filters_frame.add({
    type = "scroll-pane",
    name = "filters_scroll_pane",
    direction = "vertical",
    style = const.logistic_items_scroll_pane,
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

-- Toggle the main frame for the player, opening a new frame if one does not
-- exist, or closing it if it does.
---@param player LuaPlayer
function main_gui.toggle(player)
  if not main_gui.valid(player.index) then
    remote_view.enter(player)
    main_gui.build(player)
  else
    main_gui.destroy(player.index)
    remote_view.exit(player)
  end
end

return main_gui
