# encoding: utf-8

When(/^I see a media entry$/) do
  visit media_resources_path
  wait_until {not all(".ui-resource[data-type='media-entry']").empty?}
end

Then(/^I can browse for similar entries$/) do
  @media_entry = MediaEntry.find all(".ui-resource[data-type='media-entry']").first[:"data-id"]
  all(".ui-resource[data-type='media-entry'] .ui-thumbnail-meta").first.click
  all(".ui-resource[data-type='media-entry'] .ui-thumbnail-action-browse").first.click
  current_path.should == browse_media_resource_path(@media_entry)
  page.should have_content "Nach vergleichbaren Inhalten stöbern"
end