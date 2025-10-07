local const = require("const")

local shortcut_icons = {
  {
    icon = "__core__/graphics/icons/mip/logistic-connection.png",
    icon_size = 32,
    tint = { 0, 0, 0 },
  },
}

data:extend({
  {
    type = "custom-input",
    name = const.toggle_interface_id,
    key_sequence = "CONTROL + L",
    order = "a",
    localised_name = {
      "",
      { "gui-permissions-names.OpenGui" },
      " ",
      { "logistic_group_explorer-name.logistic-groups" },
    },
  },
  {
    type = "shortcut",
    name = const.toggle_interface_shortcut,
    action = "lua",
    associated_control_input = const.toggle_interface_id,
    hidden_in_factoriopedia = true,
    icons = shortcut_icons,
    small_icons = shortcut_icons,
    localised_name = { "logistic_group_explorer-name.logistic-groups" },
  },
  {
    type = "custom-input",
    name = const.focus_search_id,
    key_sequence = "",
    linked_game_control = "focus-search",
  },
})
