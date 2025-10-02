local to_lower_func = helpers.compare_versions(helpers.game_version, "2.0.67") >= 0 and helpers.multilingual_to_lower
  or string.lower

function update_search_results(player_index)
  local guis = storage.guis[player_index]

  local query = guis.search_box.text

  for _, table in ipairs({ guis.members_table.children, guis.filters_table.children }) do
    for _, member in pairs(table) do
      if query == "" then
        member.visible = true
      elseif member.tags.name == nil then
        member.visible = false
      else
        member.visible = string.find(to_lower_func(member.tags.name), to_lower_func(query), 1, true) ~= nil
      end
    end
  end
end
