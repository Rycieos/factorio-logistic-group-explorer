local const = require("const")

local style = data.raw["gui-style"]["default"]

style[const.subheader_no_filler_frame] = {
  type = "frame_style",
  parent = "subheader_frame",
  use_header_filler = false,
  drag_by_title = false,
  title_style = {
    type = "label_style",
    parent = "subheader_caption_label",
  },
}
style[const.right_side_no_spacer_frame] = {
  type = "frame_style",
  parent = "right_side_frame",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0,
  },
}
style[const.logistic_items_scroll_pane] = {
  type = "scroll_pane_style",
  parent = "logistic_gui_items_scroll_pane",
  width = const.slot_size * const.slot_count + 12,
  minimal_height = const.slot_size,
}
style[const.no_hover_count_label] = {
  type = "label_style",
  parent = "count_label",
  parent_hovered_font_color = { 1, 1, 1 },
  rich_text_setting = "disabled",
}
style[const.no_click_slot_button] = {
  type = "button_style",
  parent = "slot_button",
  -- Same as hovered.
  clicked_graphical_set = {
    base = { border = 4, position = { 80, 736 }, size = 80 },
    shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
    glow = offset_by_2_rounded_corners_glow(default_glow_color),
  },
  clicked_vertical_offset = 0,
  left_click_sound = {},
}
