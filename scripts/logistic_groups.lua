function populate_logistic_group(player)
  local guis = storage.guis[player.index]

  local group_name = guis.groups_list.get_item(guis.groups_list.selected_index)
  guis.group_label.caption = group_name

  local group = player.force.get_logistic_group(group_name)
  if not group then
    return
  end

  guis.members_table.clear()
  for _, member in pairs(group.members) do
    if member.valid and member.is_manual then
      local entity = member.owner
      local name = entity.name
      if entity.type == "ghost" then
        name = entity.ghost_name
      end

      surface = entity.surface
      if surface.localised_name then
        surface = surface.localised_name
      elseif surface.planet then
        surface = { "", "[planet=" .. surface.planet.name .. "] ", surface.planet.prototype.localised_name }
      elseif surface.platform then
        surface = "[space-platform=" .. surface.platform.index .. "] " .. surface.platform.name
      else
        surface = surface.name
      end
      tooltip = { "", "[font=default-semibold][color=cyan]", { "factoriopedia.surface" }, ":[/color][/font] ", surface }

      if entity.type == "character" and entity.player then
        table.insert(tooltip, {
          "",
          "\n[font=default-semibold][color=cyan]",
          { "gui-players.name" },
          ":[/color][/font] ",
          entity.player.name,
        })
      end

      guis.members_table.add({
        type = "sprite-button",
        style = "slot_button",
        sprite = "entity/" .. name,
        elem_tooltip = { type = "entity", name = name },
        tooltip = tooltip,
        toggled = false,
      })
    end
  end

  guis.filters_table.clear()
  for _, filter in pairs(group.filters) do
    guis.filters_table.add({
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
