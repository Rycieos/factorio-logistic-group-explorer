local to_lower_func = helpers.compare_versions(helpers.game_version, "2.0.67") >= 0 and helpers.multilingual_to_lower
  or string.lower

local search = {}

function search.update_search_results(guis, player)
  local query = guis.search_box.text

  for _, table in ipairs({ guis.members_table.children, guis.filters_table.children }) do
    for _, member in pairs(table) do
      if query == "" then
        member.visible = true
      elseif member.tags.name == nil then
        member.visible = false
      else
        if
          player
          and not member.tags.translated_name
          and not member.tags.translation_req_id
          and member.tags.localised_name
        then
          local tags = member.tags
          tags.translation_req_id = player.request_translation(member.tags.localised_name)
          -- Note that the API returns tags as a simple table, meaning any
          -- modifications to it will not propagate back to the game. Thus, to
          -- modify a set of tags, the whole table needs to be written back to
          -- the respective property.
          member.tags = tags
        end
        member.visible = string.find(to_lower_func(member.tags.name), to_lower_func(query), 1, true) ~= nil
        if not member.visible and member.tags.translated_name then
          member.visible = string.find(to_lower_func(member.tags.translated_name), to_lower_func(query), 1, true) ~= nil
        end
      end
    end
  end
end

function search.update_string_translation(guis, event)
  for _, table in ipairs({ guis.members_table.children, guis.filters_table.children }) do
    for _, member in pairs(table) do
      if member.tags.translation_req_id == event.id or member.tags.localised_name == event.localised_string then
        local tags = member.tags
        tags.translated_name = event.result
        member.tags = tags
      end
    end
  end
  search.update_search_results(guis, nil)
end

return search
