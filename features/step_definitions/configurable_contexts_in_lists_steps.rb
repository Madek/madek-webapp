Then(/^There is a element with the data\-context\-name "(.*?)" in the ui\-resource\-body$/) do |name|
  expect(find(".ui-resource-body *[data-context-name='#{name}']")).to be
end
