local const = require("const")
local player_data = require("scripts.player_data")
local signal_util = require("scripts.signal_util")
local util = require("scripts.util")

local groups = {}

---@class SignalData
---@field name? string
---@field localised_name? LocalisedString
---@field translation_req_id? uint32
---@field translated_name? string

---@class EntityData: SignalData
---@field entity_index uint32
---@field surface uint32
---@field position MapPosition

-- Fill the member and filter tables with sprite buttons.
---@param player LuaPlayer
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

  -- We know we will get a string back, as that is what we pass in.
  local group_name = guis.groups_list.get_item(guis.groups_list.selected_index) --[[@as string]]
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
      -- Add localised_name for searching.
      local localised_name = entity.localised_name
      if entity.type == "entity-ghost" then
        name = entity.ghost_name
        localised_name = entity.ghost_localised_name
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
      local tooltip = { "", "[font=default-semibold]", { "factoriopedia.surface" }, ":[/font] ", surface }

      if entity.type == "character" and entity.player then
        table.insert(tooltip, {
          "",
          "\n[font=default-semibold]",
          { "gui-players.name" },
          ":[/font] ",
          entity.player.name,
        })
      end

      entities[index] = entity
      local button = guis.members_table.add({
        type = "sprite-button",
        style = member.active and "slot_button" or "red_slot_button",
        sprite = "entity/" .. name,
        elem_tooltip = { type = "entity-with-quality", name = name, quality = entity.quality.name },
        tooltip = tooltip,
        toggled = false,
        quality = entity.quality.name,
        ---@type EntityData
        tags = {
          name = name,
          localised_name = localised_name,
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
      local tooltip = nil

      -- import_from will always show some planet, even if running without an expansion binary.
      if script.feature_flags.space_travel then
        tooltip = { "" }
        if filter.minimum_delivery_count then
          table.insert(tooltip, {
            "",
            "[font=default-semibold]",
            { "gui-orbital-request.custom-minimal-payload" },
            ":[/font] ",
            filter.minimum_delivery_count,
          })
          if filter.import_from then
            table.insert(tooltip, "\n")
          end
        end

        if filter.import_from then
          table.insert(tooltip, {
            "",
            "[font=default-semibold]",
            { "gui-orbital-request.import-from" },
            ":[/font] [space-location=",
            filter.import_from.name,
            "] ",
            filter.import_from.localised_name,
          })
        end
      end

      -- Add localised_name for searching.
      local type_prototype = signal_util.to_prototype(filter.value)

      local button = guis.filters_table.add({
        type = "sprite-button",
        style = const.no_click_slot_button,
        sprite = signal_util.to_sprite_path(filter.value),
        elem_tooltip = signal_util.to_elem_id(filter.value),
        tooltip = tooltip,
        toggled = false,
        number = filter.min,
        ---@type SignalData
        tags = {
          name = type_prototype.name,
          localised_name = type_prototype.localised_name,
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
      })
    end
  end
end

return groups
