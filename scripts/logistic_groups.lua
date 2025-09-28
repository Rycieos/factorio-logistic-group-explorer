function populate_logistic_group(player, group_name)
  local guis = storage.guis[player.index]

  guis.group_label.caption = group_name

  local group = player.force.get_logistic_group(group_name)
  if not group then return end

  for _, member in pairs(group.members) do
    if member.valid and member.is_manual then
      local name = member.owner.name
      if member.owner.type == "ghost" then
        name = member.owner.ghost_name
      end
      guis.members_table.add({
        type = "sprite-button",
        style = "slot_button",
        sprite = "entity/" .. name,
        elem_tooltip = { type = "entity", name = name },
        tooltip = { "None" },
        toggled = false,
      })
    end
  end

  for _, filter in pairs(group.filters) do
    guis.contents_table.add({
      type = "sprite-button",
      style = "slot_button",
      sprite = filter.value.type .. "/" .. filter.value.name,
      elem_tooltip = { type = filter.value.type, name = filter.value.name },
      tooltip = { "None" },
      toggled = false,
      quality = filter.value.quality,
      number = filter.min,
    })
  end
end
