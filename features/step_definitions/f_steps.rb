# -*- encoding : utf-8 -*-

Then /^for each context I see the label and description and the link to that context$/ do
  all(".ui-contexts .ui-context").each do |ui_context|
    context = Context.find ui_context[:"data-name"]
    ui_context.should have_content context.label.to_s
    ui_context.should have_content context.description.to_s
    ui_context.find("a[href='#{context_path(context)}']").should have_content context.label.to_s
  end
end

Then /^for each person I see the id$/ do
  expect{find("th.id")}.not_to raise_error
end


