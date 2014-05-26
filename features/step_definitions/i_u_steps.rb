# -*- encoding : utf-8 -*-
Then /^I upload some media entries$/ do
  visit import_path
  step 'I attach the file "images/berlin_wall_01.jpg"'
  step 'I attach the file "images/berlin_wall_02.jpg"'
  step 'I attach the file "images/date_should_be_1990.jpg"'
  step 'I click on the link "Weiter"'
  step 'I wait until I am on the "/import/permissions" page'
end

Then /^I upload some files to my dropbox$/ do
  @dir = "/ftp_test"
  dropbox_test_dir = File.join(@app_settings.dropbox_root_dir, @current_user.dropbox_dir_name, @dir)
  FileUtils.mkdir_p dropbox_test_dir
  @file_paths = Dir.glob("#{Rails.root}/features/data/images/*.jpg")
  FileUtils.cp_r(@file_paths, dropbox_test_dir)
end

Then (/^I upload the image "(.*?)" via dropbox$/) do |file_name|
  `cp #{Rails.root.join 'features','data','images',file_name} #{@current_user.dropbox_dir(@app_settings)}`
end

Then /^I use the highlight used vocabulary action$/ do
  find("#ui-highlight-used-terms").click
end

Then /^I use some filters$/ do
  @used_filter = []
  step 'I open the filter'
  (1..3).to_a.each do
    wait_until { page.evaluate_script("jQuery.active") == 0 }
    wait_until { all(".filter-panel *[data-value]:not(.active)").size > 0}
    filter_item = all(".filter-panel *[data-value]:not(.active)").shuffle.first
    context_element = filter_item.find(:xpath, ".//ancestor::*[@data-context-name]")
    key_element = filter_item.find(:xpath, ".//ancestor::*[@data-key-name]")
    @used_filter.push :key_name => key_element["data-key-name"],
                      :context => context_element["data-context-name"], 
                      :value => filter_item["data-value"]
    context_element.find("a").click unless context_element.find("a")[:class] =~ /open/
    key_element.find("a").click unless key_element.find("a")[:class] =~ /open/
    filter_item.click
  end
end

Then /^I use the create filter set option$/ do
  find("a#nexuses").click
  find("a#create-filter-set").click
end


