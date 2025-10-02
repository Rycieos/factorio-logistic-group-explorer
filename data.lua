const = require("const")

data:extend({
  {
    type = "custom-input",
    name = const.toggle_interface_id,
    key_sequence = "CONTROL + L",
    order = "a",
  },
  {
    type = "custom-input",
    name = const.focus_search_id,
    key_sequence = "",
    linked_game_control = "focus-search",
  },
})

local style = data.raw["gui-style"]["default"]

style.lge__subheader_frame_no_filler = {
  type = "frame_style",
  parent = "subheader_frame",
  use_header_filler = false,
  drag_by_title = false,
  title_style = {
    type = "label_style",
    parent = "subheader_caption_label",
  },
}
style.lge__right_side_frame_no_spacer = {
  type = "frame_style",
  parent = "right_side_frame",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0,
  },
}
style.lge__logistic_items_scroll_pane = {
  type = "scroll_pane_style",
  parent = "logistic_gui_items_scroll_pane",
  width = const.slot_size * const.slot_count + 12,
  minimal_height = const.slot_size,
}
