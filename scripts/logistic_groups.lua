player_data = require("scripts.player_data")
util = require("scripts.util")

groups = {}

function groups.populate_logistic_group(player)
  local data = player_data(player.index)
  local guis = data.guis

  local button = guis.group_delete_button
  if
    player.permission_group and not player.permission_group.allows_action(defines.input_action.delete_logistic_group)
  then
    button.enabled = false
  else
    button.enabled = guis.groups_list.selected_index > 0
  end

  if guis.groups_list.selected_index == 0 then
    return
  end

  local group_name = guis.groups_list.get_item(guis.groups_list.selected_index)
  data.last_group = group_name
  guis.group_label.caption = group_name

  local group = player.force.get_logistic_group(group_name)
  if not group then
    return
  end

  local entities = {}
  data.entities = entities

  guis.members_table.clear()
  for index, member in pairs(group.members) do
    if member.valid and member.is_manual then
      local entity = member.owner
      local name = entity.name
      if entity.type == "entity-ghost" then
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

      entities[index] = entity
      local button = guis.members_table.add({
        type = "sprite-button",
        style = member.active and "slot_button" or "red_slot_button",
        sprite = "entity/" .. name,
        -- As of v2.0.69 quality here does nothing.
        elem_tooltip = { type = "entity", name = name, quality = entity.quality.name },
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
      if entity.type == "entity-ghost" then
        local ghost_icon = button.add({
          type = "sprite",
          sprite = "entity/entity-ghost",
          resize_to_sprite = false,
        })
        -- Hack to get it farther into the top-left corner.
        ghost_icon.style.padding = { -4, 4, 4, -4 }
        ghost_icon.style.size = 20
      end
    end
  end

  guis.filters_table.clear()
  for _, filter in pairs(group.filters) do
    if filter.value then
      -- Not an empty slot.
      local obj = { type = filter.value.type, name = filter.value.name }

      local button = guis.filters_table.add({
        type = "sprite-button",
        style = "slot_button",
        sprite = obj.type .. "/" .. obj.name,
        elem_tooltip = obj,
        toggled = false,
        number = filter.min,
        tags = {
          name = obj.name,
        },
      })

      local quality = filter.value.quality
      local quality_sprite = nil
      if not quality then
        quality_sprite = "utility/any_quality"
      elseif prototypes.quality[quality].draw_sprite_by_default then
        quality_sprite = "quality/" .. quality
      end

      if quality_sprite or filter.max then
        local flow = button.add({
          type = "flow",
          direction = "vertical",
        })

        local max_count = flow.add({
          type = "label",
          style = const.no_hover_count_label,
          caption = filter.max and util.format_number(filter.max) or nil,
          ignored_by_interaction = true,
        })
        max_count.style.width = 33
        max_count.style.top_margin = 4
        max_count.style.horizontal_align = "right"

        if quality_sprite then
          local quality_flow = flow.add({
            type = "flow",
            direction = "horizontal",
          })
          quality_flow.style.top_margin = -10

          if filter.value.comparator and filter.value.comparator ~= "=" then
            local comparator_label = quality_flow.add({
              type = "label",
              style = const.no_hover_count_label,
              caption = filter.value.comparator,
              ignored_by_interaction = true,
            })
            comparator_label.style.height = 8
            comparator_label.style.right_margin = -4
          end

          local quality_icon = quality_flow.add({
            type = "sprite",
            sprite = quality_sprite,
            resize_to_sprite = false,
            ignored_by_interaction = true,
          })
          quality_icon.style.size = 14
        end
      end
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
