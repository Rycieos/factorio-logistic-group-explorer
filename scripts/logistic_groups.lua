groups = {}

local function update_delete_button(player)
  local guis = storage.guis[player.index]
  local button = guis.group_delete_button

  if
    player.permission_group and not player.permission_group.allows_action(defines.input_action.delete_logistic_group)
  then
    button.enabled = false
    return
  end

  button.enabled = guis.groups_list.selected_index > 0
end

function groups.populate_logistic_group(player)
  local guis = storage.guis[player.index]

  update_delete_button(player)

  if guis.groups_list.selected_index == 0 then
    return
  end

  local group_name = guis.groups_list.get_item(guis.groups_list.selected_index)
  storage.last_group[player.index] = group_name
  guis.group_label.caption = group_name

  local group = player.force.get_logistic_group(group_name)
  if not group then
    return
  end

  storage.entities[player.index] = {}
  guis.members_table.clear()
  for index, member in pairs(group.members) do
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

      storage.entities[player.index][index] = entity
      guis.members_table.add({
        type = "sprite-button",
        style = member.active and "slot_button" or "red_slot_button",
        sprite = "entity/" .. name,
        elem_tooltip = { type = "entity", name = name },
        tooltip = tooltip,
        toggled = false,
        quality = entity.quality.name,
        tags = {
          name = name,
          surface = entity.surface_index,
          position = entity.position,
          entity_index = index,
        },
        raise_hover_events = true,
      })
    end
  end

  guis.filters_table.clear()
  for _, filter in pairs(group.filters) do
    if filter.value then
      -- Not an empty slot.
      local obj = { type = filter.value.type, name = filter.value.name }

      guis.filters_table.add({
        type = "sprite-button",
        style = "slot_button",
        sprite = obj.type .. "/" .. obj.name,
        elem_tooltip = obj,
        toggled = false,
        quality = filter.value.quality,
        number = filter.min,
        tags = {
          name = obj.name,
        },
      })
    else
      guis.filters_table.add({
        type = "sprite-button",
        style = "slot_button",
        toggled = false,
        tags = {
          name = nil,
        },
      })
    end
  end
end

return groups
