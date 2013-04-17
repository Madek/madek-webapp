Then /^I can filter by the type of media resources$/ do
  find("[data-context-name='media_resources']").click
  find("[data-key-name='type']").click

  # MediaEntry
  find("[data-value='MediaEntry']").click
  wait_until {all(".ui-resource[data-id]").size > 0}
  expect(all(".ui-resource[data-id]").size == all(".ui-resource[data-id][data-type='media-entry']").size).to be_true
  find("[data-value='MediaEntry']").click

  # MediaSet
  find("[data-value='MediaSet']").click
  wait_until {all(".ui-resource[data-id]").size > 0}
  expect(all(".ui-resource[data-id]").size == all(".ui-resource[data-id][data-type='media-set']").size).to be_true
  find("[data-value='MediaSet']").click

  # FilterSet
  find("[data-value='FilterSet']").click
  wait_until {all(".ui-resource[data-id]").size > 0}
  expect(all(".ui-resource[data-id]").size == all(".ui-resource[data-id][data-type='filter-set']").size).to be_true
  find("[data-value='FilterSet']").click
end
