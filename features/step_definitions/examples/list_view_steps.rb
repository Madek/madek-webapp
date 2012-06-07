# coding: UTF-8

When /^I see a list of sets in list view$/ do
  visit media_resources_path(:type => "media_sets")
  wait_until { find("#bar .layout .icon[data-type='list']") }.click
end

When /^I see the "(.*?)" meta key of a set/ do |meta_key|
  binding.pry
  wait_until(45){ find(".context.nutzung .meta_datum") }
  binding.pry
  case meta_key
    when"children"
      wait_until { find("dt", :text => "Enthält") }
    when "parents"
      wait_until { find("dt", :text => "Enthalten in") }
  end
end

Then /^I see the number and type of children$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^there is one number for media entries$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^there is one number for sets$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^one of the resources has parents$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I see the number and type of parents$/ do
  pending # express the regexp above with the code you wish you had
end
