# -*- encoding : utf-8 -*-

# see "the_steps.rb"
# see "there_are_steps.rb" 
# see "there_is_steps.rb"

Then /^this context is removed from set A$/ do
  expect(@media_set_a.individual_contexts.include?(@individual_context)).to be_false
end

Then /^This logo_url appears as the logo of this instance$/  do
  visit "/my"
  find ".app-header .ui-header-brand img[src='#{@logo_url}']"
end

Then /^those contexts are no longer connected to that set$/ do
  @individual_contexts.each do |context|
    expect(@media_set.reload.individual_contexts.include? context).to be_false
  end
end

Then /^those files are getting imported during the upload$/ do
  visit import_path
  @file_paths.each do |file_path|
    matcher = /#{@dir}\/.*?#{Pathname.new(file_path).basename.to_s}.*?\(Dropbox\)/
    find("#dropbox_filelist .plupload_dropbox.plupload_transfer", :text => matcher)
  end
  step 'I click on the link "Weiter..."'
  wait_until([3*Capybara.default_wait_time,60].max){all("#dropbox_filelist").size == 0}
  expect(@current_user.incomplete_media_entries.size).to eq @file_paths.size
end

Then /^two files with missing metadata are marked$/ do
  wait_until{all("ul.ui-resources li.ui-invalid").size > 1}
  expect(all("ul.ui-resources li.ui-invalid").size).to eq 2
end

Then /^Those links appear in the footer of the path "(.*?)"$/  do |path|
  visit path
  @links.each do |k,v| 
    find(".app-footer").find("a[href='#{v}']",text: k)
  end
end
