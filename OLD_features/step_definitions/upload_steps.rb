# coding: UTF-8

When /^I upload the file "([^"]*)" relative to the Rails directory$/ do |path|
  f = "#{Rails.root}/#{path}"
  # Need to copy this file to a temporary new file because files are moved away after succesful
  # uploads!
  f_temp = "#{Rails.root}/tmp/temp_#{File.basename(f)}"
  FileUtils.cp(f, f_temp)
  uploaded_data = ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                                         :tempfile=> File.new(f_temp, "r"),
                                                         :filename=> File.basename(f))
  @media_entry_incomplete = @current_user.incomplete_media_entries.create(:uploaded_data => uploaded_data)
  @media_entry_incomplete.valid?.should be_true
  @media_entry_incomplete.persisted?.should be_true
  @media_entry_incomplete.is_a?(MediaEntryIncomplete).should be_true
end

When /^I upload a file$/ do
  @path = "features/data/images/berlin_wall_01.jpg"
  step "I upload the file \"#{@path}\" relative to the Rails directory"
end

When /^I upload several files$/ do
  @path = "features/data/images/berlin_wall_01.jpg"
  step "I upload the file \"#{@path}\" relative to the Rails directory"
  @path2 = "features/data/images/berlin_wall_02.jpg"
  step "I upload the file \"#{@path2}\" relative to the Rails directory"
end


Then /^I can assign the Title to all the other files I just uploaded$/ do
  find(".edit_meta_datum_field[data-field_name='title'] .button").click
  wait_until { all(".media_resource_selection .saving").size == 0 }
  MediaResource.find_by_title("Test image for mass assignment of values").size.should == 2
end


Then /^I can assign the Copyright to all the other files I just uploaded$/ do
  find(".edit_meta_datum_field[data-field_name='copyright notice'] .button").click
  wait_until { all(".media_resource_selection .saving").size == 0 }
  # TODO rather use the SQL query once we have normalized the schema
  # MediaResource.joins(:meta_data => :meta_key).select("meta_data.*").where("meta_keys.label = ?", "copyright notice").where("meta_data.value = ?","Tester Two").size.should == 2
  MetaDatum.all.select{|md| md.value == "Tester Two"}.size.should == 2
end

Then /^the file is attached to a media entry$/ do
  @media_entry_incomplete.media_file.valid?.should be_true
  @media_entry_incomplete.media_file.persisted?.should be_true
  @media_entry_incomplete.media_file.filename.should == File.basename("#{Rails.root}/#{@path}")  
end

Then /^I can set the permissions for the media entry during the upload process$/ do
  step 'I upload a file'
  visit permissions_import_path
  wait_for_css_element("#permissions .line")
end

Then /^I add the media entry to a set called "([^"]*)"$/ do |arg1|
  @media_entry_incomplete.media_sets.empty?.should be_true
  visit "/import/organize"
  find("button", :text => "Einträge zu einem Set hinzufügen").click
  step 'I should see the "Konzepte" set inside the widget'
  step 'I select "Konzepte" as parent set'
  step 'I submit the selection widget'
end


When /^I upload a file with a file size greater than 1.4 GB$/ do
  begin
    path = File.join(::Rails.root, "tmp/file_biger_then_1_4_GB.mov") 
    `dd if=/dev/zero of=#{path} count=3000000` 
    visit "/import"
    attach_file(find("input[type='file']")[:id], path)
  ensure
    File.delete path
  end
end

Then /^the system gives me a warning telling me it's impossible to upload so much through the browser$/ do
  find(".dialog").should have_content "Die ausgewählte Datei war zu gross"
end

Then /^the warning includes instructions for an FTP upload$/ do
  find(".dialog").should have_content "FTP"
end

When /^I have uploaded some files to my dropbox$/ do
  user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, @current_user.dropbox_dir_name)
  FileUtils.cp_r(Dir.glob("#{Rails.root}/features/data/images/*.jpg"), user_dropbox_root_dir)
end

When /^I start a new upload process$/ do
  visit "/import"
end

Given /^all users have dropboxes$/ do
  User.all.each do |user|
    user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, user.dropbox_dir_name)
    FileUtils.mkdir_p(user_dropbox_root_dir)
  end
end

Then /^I can choose files from my dropbox instead of uploading them through the browser$/ do
  user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, @current_user.dropbox_dir_name)
  #TODO perhaps merge this logic to @user.dropbox_files
  dropbox_files = Dir.glob(File.join(user_dropbox_root_dir, '**', '*')).
                  select {|x| not File.directory?(x) }.
                  map {|f| {:dirname=> File.dirname(f).gsub(user_dropbox_root_dir, ''),
                            :filename=> File.basename(f),
                            :size => File.size(f) } }
  dropbox_files.each do |file|
    page.should have_content file[:filename]
    page.should have_content file[:dirname]
  end
end

When /^I have uploaded a directory containing files to my dropbox$/ do
  @user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, @current_user.dropbox_dir_name)
  FileUtils.cp_r(Dir.glob("#{Rails.root}/features/data/images"), @user_dropbox_root_dir)
end

When /^I have started uploading some files$/ do
  visit "/import"

  # Need to copy this file to a temporary new file because files are moved away after succesful
  # uploads!
  ["features/data/images/berlin_wall_01.jpg", "features/data/images/berlin_wall_02.jpg"].each do |f|
      f_temp = "#{Rails.root}/tmp/#{File.basename(f)}"
      FileUtils.cp(Rails.root + f, f_temp)
      attach_file(find("input[type='file']")[:id], f_temp )
  end
  find(".plupload_start").click
end

When /^I cancel the upload$/ do
  if  page.driver.is_a? Capybara::Poltergeist::Driver
    page.execute_script(%Q[window.alert = function(){return true;}])
    step 'follow "Abbrechen"'
  else
    step 'follow "Abbrechen"'
    page.driver.browser.switch_to.alert.accept
  end
end

Then /^the uploaded files are still there$/ do
  visit "/import"
  wait_for_css_element("li.plupload_done")
end

Then /^the upload process ends$/ do
  page.should have_content("Import abgebrochen")
end

When /^I uploading some files from the dropbox and from the filesystem$/ do
  @user_dropbox_root_dir = File.join(AppSettings.dropbox_root_dir, @current_user.dropbox_dir_name)
  step 'I have uploaded some files to my dropbox'
  visit "/import"
  attach_file(find("input[type='file']")[:id], File.join(::Rails.root, "features/data/images/berlin_wall_01.jpg") )
  attach_file(find("input[type='file']")[:id], File.join(::Rails.root, "features/data/images/berlin_wall_02.jpg") )
  attach_file(find("input[type='file']")[:id], File.join(::Rails.root, "features/data/images/date_should_be_1990.jpg") )
  attach_file(find("input[type='file']")[:id], File.join(::Rails.root, "features/data/images/date_should_be_2011-05-30.jpg") )
  find(".plupload_start").click
end

When /^I delete some fo those after the upload$/ do
  wait_until { find("#uploader_filelist li span",:text => "berlin_wall_01.jpg").find(:xpath, "../..") }
  deleted_plupload_file_element_after_upload = find("#uploader_filelist li span",:text => "berlin_wall_01.jpg").find(:xpath, "../..")
  deleted_plupload_file_element_after_upload.find(".delete_plupload_entry").click
  page.driver.browser.switch_to.alert.accept
  
  wait_until { find("#dropbox_filelist li span",:text => "berlin_wall_01.jpg").find(:xpath, "../..") }
  deleted_dropbox_file_element_after_upload = find("#dropbox_filelist li span",:text => "berlin_wall_01.jpg").find(:xpath, "../..")
  deleted_dropbox_file_element_after_upload.find(".delete_dropbox_file").click
  page.driver.browser.switch_to.alert.accept
end

Then /^those files are deleted$/ do
  @current_user.incomplete_media_entries.each do |element|
    element.media_file.filename.should_not == "berlin_wall_01.jpg"
  end
end

Then /^only the rest of the files are available for import$/ do
  visit import_path
  page.should_not have_content "berlin_wall_01.jpg"
  page.should have_content "berlin_wall_02.jpg"
  page.should have_content "date_should_be_1990.jpg"
  page.should have_content "date_should_be_2011-05-30.jpg"
end

When /^I import a file$/ do
  @path = "features/data/images/berlin_wall_01.jpg"
  steps %Q{
   When I upload the file "#{@path}" relative to the Rails directory
   And I go to the upload edit 
   And I fill in the metadata for entry number 1 as follows:
   |label    |value                       |
   |Titel    |into the set after uploading|
   |Rechte|some other dude             |
   And I follow "weiter..."
   And I follow "Import abschliessen"
  }
end

Then /^I want to have its original file name inside its metadata$/ do
  visit media_entry_path(@media_entry_incomplete)
  step 'I expand the "Weitere Daten" context group'
  find("#meta_data .meta_group .meta_vocab_name", :text => "Filename")
  find("#meta_data .meta_group .meta_terms", :text => File.basename(@path))
end

Then /^I want to have the date the camera took the picture on as the creation date$/ do
  pending # express the regexp above with the code you wish you had
end

And /^I try to continue in the import process$/ do
  find("#finish_meta_data").click()
end

Then /^I see an error message "([^"]*)"$/ do |msg|
  wait_until { find(".dialog") }
  page.should have_content msg
end

And /^the field "Rechte" is highlighted as invalid/ do
  find(".edit_meta_datum_field[data-field_name='copyright notice'] .status .required").should be_true
end


Then /^I see a list of my uploaded files$/ do
  wait_until{ all(".loading", :visible => true).size == 0 }
  all('.media_resource_selection .media .item_box').size.should be >= 2
  wait_until{ all(".edit_meta_datum_field", :visible => true).size > 0 }
  wait_until{ find(".attention_flag") } if MediaEntryIncomplete.any? {|me| not me.context_valid?(MetaContext.upload)}  
end


And /^I can jump to the next file$/ do
  wait_until{ all(".loading", :visible => true).size == 0 }
  wait_until { find(".navigation .next:not([disabled=disabled])") }
  next_id= find(".navigation .next")[:"data-media_resource_id"]
  find(".navigation .next").click
  wait_until { find(".navigation .current")[:"data-media_resource_id"] == next_id }
end

And /^I can jump to the previous file$/ do
  wait_until{ find(".navigation .previous:not([disabled=disabled])") }
  previous_id= find(".navigation .previous")[:"data-media_resource_id"]
  find(".navigation .previous").click
  wait_until { find(".navigation .current")[:"data-media_resource_id"] == previous_id }
end

And /^the files with missing metadata are marked$/ do
  @current_user.incomplete_media_entries.select{|me| not me.context_valid?(MetaContext.upload)}.map(&:id).each do |id|
    wait_until {all(".item_box[data-media_resource_id='#{id}'] .attention_flag").size > 0}
  end
end

And /^I can choose to list only files with missing metadata$/ do
   find(".filter input").should_not be_false
end

When /^I choose to list only files with missing metadata$/ do
  find(".filter input").click
end

Then /^only files with missing metadata are listed$/ do
  @current_user.incomplete_media_entries.select{|me| not me.context_valid?(MetaContext.upload)}.map(&:id).each do |id|
    wait_until {all(".item_box[data-media_resource_id='#{id}'] .attention_flag").size > 0}
  end
  @current_user.incomplete_media_entries.select{|me| me.context_valid?(MetaContext.upload)}.map(&:id).each do |id|
    wait_until {all(".item_box[data-media_resource_id='#{id}']",visible: true).size.should == 0}
  end 
end

Given /^MetaTerms are existing in the upload context$/ do
  step 'I am "Adam"'
  ["academic year", "epoch", "Zett_Ausgabe"].each do |key|
    visit "/admin/meta_contexts"
    find("tr",text: 'Upload').find("a",text:"View").click()
    find("a",text:'Add Key').click()
    find("select#meta_key_definition_meta_key_id").select(key)
    find("input#meta_key_definition_label_id").set(key)
    find("input#meta_key_definition_description_id").set(key)
    find("input#meta_key_definition_hint_id").set(key)
    find("input[type=submit]").click()
  end
end

Then /^I can set values for the meta data from type meta terms$/ do
  visit edit_import_path
  meta_data = @current_user.media_resources.where(:type => "MediaEntryIncomplete").first.meta_data
  
  # not_extensible_meta_terms_checkbox
  not_extensible_meta_terms_checkbox = find(".edit_meta_datum_field.meta_terms.not_extensible_list.checkboxes")
  not_extensible_meta_terms_checkbox.find("input").click
  step 'I wait for the AJAX magic to happen'
  sleep(1)
  meta_key_id = MetaKey.find_by_label not_extensible_meta_terms_checkbox["data-field_name"]
  meta_data.reload.where(:meta_key_id => meta_key_id).first.value.length.should > 0

  # extensible_meta_terms_autocomplete
  extensible_meta_terms_autocomplete = find(".edit_meta_datum_field.meta_terms.extensible_list.autocomplete")
  extensible_meta_terms_autocomplete.find(".list_toggle.button").click
  wait_until { find(".ui-menu-item a") }
  find(".ui-menu-item a").click
  step 'I wait for the AJAX magic to happen'
  wait_until { extensible_meta_terms_autocomplete.find(".success") }
  sleep(1)
  wait_until { meta_data.reload.where(:meta_key_id => meta_key_id).first.value.length > 0 }
  extensible_meta_terms_autocomplete.find("input").set "added entry"
  extensible_meta_terms_autocomplete.find("input").native.send_keys(:return)
  wait_until { extensible_meta_terms_autocomplete.find(".loading") }
  step 'I wait for the AJAX magic to happen'
  wait_until { extensible_meta_terms_autocomplete.find(".success") }
  sleep(1)
  meta_key_id = MetaKey.find_by_label extensible_meta_terms_autocomplete["data-field_name"]
  length = meta_data.reload.where(:meta_key_id => meta_key_id).first.value.length
  wait_until { meta_data.reload.where(:meta_key_id => meta_key_id).first.value.length > 1 }

  # not_extensible_meta_terms_autocomplete
  not_extensible_meta_terms_autocomplete = find(".edit_meta_datum_field.meta_terms.not_extensible_list.autocomplete")
  not_extensible_meta_terms_autocomplete.find(".list_toggle.button").click
  wait_until { find(".ui-menu-item a") }
  find(".ui-menu-item a").click
  step 'I wait for the AJAX magic to happen'
  wait_until { not_extensible_meta_terms_autocomplete.find(".success") }
  sleep(1)
  meta_key_id = MetaKey.find_by_label not_extensible_meta_terms_autocomplete["data-field_name"]
  wait_until { meta_data.reload.where(:meta_key_id => meta_key_id).first.value.length > 0 }
end


When /^I select a copyright status from the predefined ones and this status has values for each of its fields$/ do
  find(".collapsible_button").click()
  find("[data-field_name='copyright usage'] textarea").value().should_not eq("")
  find("[data-field_name='copyright url'] textarea").value().should_not eq("")
end

When /^then switch to another copyright status that has no or blank values for any of its fields$/ do
   find("[data-field_name='copyright status'] select").select("individuelle")
end

Then /^each of these fields of the copyright status are cleared$/ do
  find("[data-field_name='copyright usage'] textarea").value().should eq("")
  find("[data-field_name='copyright url'] textarea").value().should eq("")
end

