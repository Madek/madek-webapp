# -*- encoding : utf-8 -*-

Then /^I can filter so that I see only the media resources by each of the owners of any media resources shown$/ do
  a = find("#filter_area .permissions")
  a.find("h3", :text => "Berechtigung").click
  a.find(".key h3", :text => "Eigentümer/in").click
  c = a.find(".key .term")
  c.find(".text").text.should_not be_empty
  count = c.find(".count").text.to_i
  c.click
  wait_until { find(".results") }
  wait_until { find(".results .pagination", :text => /#{count} Resultate/) }
end

Then /^I can filter so that I see only the media resources that have view permissions relating to each of those groups$/ do
  a = find("#filter_area .permissions")
  a.find("h3", :text => "Berechtigung").click
  a.find(".key h3", :text => "Arbeitsgruppen").click
  c = a.find(".key .term")
  c.find(".text").text.should_not be_empty
  count = c.find(".count").text.to_i
  c.click
  wait_until { find(".results") }
  wait_until { find(".results .pagination", :text => /#{count} Resultate/) }
end
