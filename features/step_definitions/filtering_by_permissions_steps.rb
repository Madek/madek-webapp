# -*- encoding : utf-8 -*-

Then /^I can filter so that I see only the media resources that have view permissions relating to each of those (.*?)$/ do |arg1|
  a = find("#filter_area .permissions")
  a.find("h3", :text => "Berechtigung").click
  label = case arg1
    when "owners"
      "Eigentümer/in"
    when "groups"
      "Arbeitsgruppen"
    when "permissions"
      "Zugriff"
  end
  a.find(".key h3", :text => label).click
  c = a.find(".key .term")
  c.find(".text").text.should_not be_empty
  count = c.find(".count").text.to_i
  c.click
  wait_until { find(".results") }
  wait_until { find(".results .pagination", :text => /#{count} Resultate/) }
end

Then /^I can filter by the "(.*?)" scope$/ do |filter|
  step 'I go to the media resources'
  step 'I see the filter panel'
  a = find("#filter_area .permissions")
  a.find("h3", :text => "Berechtigung").click
  a.find(".key h3", :text => "Zugriff").click
  label = case filter
    when "My content"
      "Meine"
    when "Content assigned to me"
      "Mir anvertraute"
    when "Available to the public"
      "Öffentliche"
  end  
  c = a.find(".key .term", :text => label)
  count = c.find(".count").text.to_i
  c.click
  wait_until { find(".results") }
  wait_until { find(".results .pagination", :text => /#{count} Resultate/) }
end
