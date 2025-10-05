local mod_name = "logistic_group_explorer"

return {
  slot_size = 40,
  slot_count = 10,

  mod_name = mod_name,

  main_frame_id = mod_name .. "_main_frame",

  toggle_interface_id = mod_name .. "_toggle_interface",
  toggle_interface_shortcut = mod_name .. "_toggle_interface_shortcut",
  focus_search_id = mod_name .. "_focus_search",

  subheader_no_filler_frame = mod_name .. "_subheader_no_filler_frame",
  right_side_no_spacer_frame = mod_name .. "_right_side_no_spacer_frame",
  logistic_items_scroll_pane = mod_name .. "_logistic_items_scroll_pane",
  no_hover_count_label = mod_name .. "_no_hover_count_label",
  no_click_slot_button = mod_name .. "_no_click_slot_button",
}
