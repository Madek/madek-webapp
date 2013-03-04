
Then /^I can see several images$/ do
  wait_until{all("li[data-media_type='image']").size > 0}
end

When /^I can see several resources$/ do
  wait_until{ all("li.ui-resource").size > 0 }
end

When /^All resources that I can see have public view permission$/ do
  ids = all("li.ui-resource").map{|el| el['data-id'].to_i}
  view_permissions = MediaResource.where(id: ids).map(&:view)
  expect(view_permissions.size).to be > 0
  expect(view_permissions.all?{|p| p == true} ).to  be_true
end

When /^I visit the path of a randomly chosen media_entry with public view and download permission$/ do
  visit "/media_entry/" + MediaEntry.where(download: true,view: true).pluck(:id).sample.to_s
end

Then /^I can download the entry$/ do
  raise "check with susanne"
end
