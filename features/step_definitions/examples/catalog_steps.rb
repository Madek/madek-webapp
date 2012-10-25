def preload_catalog_set_and_div
  @catalog_set = MediaSet.find(AppSettings.catalog_set_id)
  @catalog_div = find("section.content_body > .page_title_left", :text => @catalog_set.title).find(:xpath, "./..")
end

When /^I select a set to be the catalog$/ do
  visit special_admin_media_sets_path
  @set = MediaSet.where(MediaSet.arel_table[:id].not_eq(AppSettings.catalog_set_id)).first
  AppSettings.catalog_set_id.should_not == @set.id
  find("input#catalog_set_id_%d" % @set.id).click
  find("input[type='submit']").click
end

Then /^it is set as catalog for this Madek instance$/ do
  AppSettings.catalog_set_id.should == @set.id
end

Then /^I see the content of the set that is defined as the catalog$/ do
  step 'I see the title of the catalog'
end

Given /^I am viewing the catalog$/ do
  step 'I am on the dashboard'
  preload_catalog_set_and_div
end

Then /^I see the categories of that catalog$/ do
  @categories = @catalog_div.all(".item_box")
  @categories.size.should > 0
end

Then /^the categories are filter sets$/ do
  @categories.each do |category|
    FilterSet.exists?(category[:href].scan(/\d+/).last).should == true
  end
end

Then /^I see the title of the catalog$/ do
  preload_catalog_set_and_div
  @catalog_div.find(".page_title_left").text.should == @catalog_set.title
end

Then /^I see the title of the catalog: "(.*?)"$/ do |arg1|
  @catalog_div.find(".page_title_left").text.should == arg1
end

Then /^I see the description of the catalog$/ do
  @catalog_div.find(".page_title_left + div").text.should == @catalog_set.meta_data.get_value_for("description")
end

Then /^I see the children of the catalog, which are called categories$/ do
  @catalog_div.all("a.item_box").size.should > 0
end

Then /^I see the title and description of each of these categories$/ do
  @catalog_div.all("a.item_box").each do |category|
    category.find("h4").text.should_not be_empty
    category.text.gsub(category.find("h4").text, '').should_not be_empty
  end
end

Then /^I can choose to navigate to one of these categories$/ do
  @catalog_div.find("a.item_box").click
end

Given /^I am viewing the category called "(.*?)"$/ do |arg1|
  step 'I am viewing the catalog'
  @category_set = @catalog_set.child_media_resources.media_sets.detect{|x| x.title == arg1}
  @catalog_div.find("a.item_box > h4", :text => arg1).click
end

Then /^I see the title of that category: "(.*?)"$/ do |arg1|
  find("section.content_body > h3", :text => arg1)
end

Then /^I see the description of that category$/ do
  find("section.content_body > div").text.should_not be_empty
end

Then /^I see the sections of the category "(.*?)"$/ do |arg1|
  all("section.content_body > a.item_box").size.should > 0
end

Then /^one of these sections is called "(.*?)"$/ do |arg1|
  find("section.content_body > a.item_box > h4", :text => arg1)
end

Then /^I see how many resources are related to that section$/ do
  all("section.content_body > a.item_box").each do |section|
    section.text.should =~ /Inhalte/
  end
end

Then /^this page's title is the title of the category itself, prefixed by catalog title$/ do
  find("section.content_body > h3", :text => "%s / %s" % [@catalog_set.title, @category_set.title])
end

Then /^I can choose to navigate to one of these sections$/ do
  find("section.content_body > a.item_box").click
end

Given /^I am viewing a section$/ do
  step 'I am viewing the catalog'
  c1 = @catalog_div.find("a.item_box")
  @category_title = c1.find("h4").text 
  c1.click
  c2 = find("section.content_body > a.item_box")
  @section_title = c2.find("h4").text 
  c2.click
end

Then /^it looks and behaves mostly like a search result page filtered according to the section's filter settings$/ do
  find("#filter_area")
  find("section.content_body.media_resources > .results")
end

Then /^unlike the search result page, this page's title is the name of the section itself prefixed by catalog title and category title$/ do
  find("section.content_body.media_resources > #bar h1", :text => "%s / %s / %s" % [@catalog_set.title, @category_title, @section_title])
end
