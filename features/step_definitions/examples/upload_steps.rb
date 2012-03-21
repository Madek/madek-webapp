# coding: UTF-8

When /^I upload the file "([^"]*)" relative to the Rails directory$/ do |path|
  f = "#{Rails.root}/#{path}"
  uploaded_data = ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                                         :tempfile=> File.new(f, "r"),
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

Then /^the file is attached to a media entry$/ do
  @media_entry_incomplete.media_file.valid?.should be_true
  @media_entry_incomplete.media_file.persisted?.should be_true
  @media_entry_incomplete.media_file.filename.should == File.basename("#{Rails.root}/#{@path}")  
end

Then /^I can set the permissions for the media entry during the upload process$/ do
  step 'I upload a file'
  visit permissions_upload_path
  wait_for_css_element("#permissions .line")
end

Then /^I add the media entry to a set called "([^"]*)"$/ do |arg1|
  @media_entry_incomplete.media_sets.empty?.should be_true
  visit "/upload/set_media_sets"
  find("button", :text => "Einträge zu einem Set hinzufügen").click
  step 'I search for "Konzepte"'
  step 'I should see the "Konzepte" set inside the widget'
  step 'I select "Konzepte" as parent set'
  step 'I submit the selection widget'
  @media_entry_incomplete.reload.media_sets.empty?.should == false
end

When "I fill in the metadata in the upload form as follows:" do |table|
  visit "/upload/edit"
  table.hashes.each do |hash|
    # Fills in the "_value" field it finds in the UL that contains
    # the "key" text. e.g. "Titel*" or "Copyright"
    text = filter_string_for_regex(hash['label'])

    list = find("ul", :text => /^#{text}/)
    if list.nil?
      raise "Can't find any input fields with the text '#{text}'"
    else
      if list[:class] == "Person"
        fill_in_person_widget(list, hash['value'], hash['options'])
      elsif list[:class] == "Keyword"
        fill_in_keyword_widget(list, hash['value'], hash['options'])
      elsif list[:class] == "MetaTerm"
        if list.has_css?("ul.meta_terms")
          set_term_checkbox(list, hash['value'])
        elsif list.has_css?(".madek_multiselect_container")
          select_from_multiselect_widget(list, hash['value'])
        else
          raise "Unknown MetaTerm interface element when trying to set '#{text}'"
        end
      elsif list[:class] == "MetaDepartment"
        puts "Sorry, can't set MetaDepartment to '#{text}', the MetaDepartment widget is too hard to test right now."

        #select_from_multiselect_widget(list, hash['value'])
      else
        # These can be either textareas or input fields, let's fill in both. It's a bit brute force,
        # can be done more elegantly by finding out whether we're dealing with a textarea or an input field.
        list.all("textarea").each do |ele|
          fill_in ele[:id], :with => hash['value'] if !ele[:id].match(/meta_data_attributes_.+_value$/).nil? and ele[:id].match(/meta_data_attributes_.+_keep_original_value$/).nil?
        end

        list.all("input").each do |ele|
          fill_in ele[:id], :with => hash['value'] if !ele[:id].match(/meta_data_attributes_.+_value$/).nil? and ele[:id].match(/meta_data_attributes_.+_keep_original_value$/).nil?
        end

      end

    end
  end
  step "I follow \"Metadaten speichern\""

  # check the simple properties for now
  @media_entry_incomplete.reload.meta_data.where("meta_key_id = ?",3).first.value.should == "Test image for uploading"
  @media_entry_incomplete.reload.meta_data.where("meta_key_id = ?",52).first.value.should == "Tester"
end

When /^I upload a file with a file size greater than 1.4 GB$/ do
  begin
    path = File.join(::Rails.root, "tmp/file_biger_then_1_4_GB.mov") 
    `dd if=/dev/zero of=#{path} count=3000000` 
    visit "/upload"
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
  visit "/upload"
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
  visit "/upload"
  attach_file(find("input[type='file']")[:id], File.join(::Rails.root, "features/data/images/berlin_wall_01.jpg") )
  attach_file(find("input[type='file']")[:id], File.join(::Rails.root, "features/data/images/berlin_wall_02.jpg") )
  find(".plupload_start").click
end

When /^I cancel the upload$/ do
  wait_for_css_element(".next:not(.disabled)")
  step 'follow "Abbrechen"'
  page.driver.browser.switch_to.alert.accept
end

Then /^the uploaded files are still there$/ do
  MediaEntryIncomplete.all[0].media_file.filename.should == "berlin_wall_01.jpg"
  MediaEntryIncomplete.all[1].media_file.filename.should == "berlin_wall_02.jpg"
end

Then /^the upload process ends$/ do
  page.should have_content("Import abgebrochen")
end

When /^I uploading some files from the dropbox and from the filesystem$/ do
  step 'I have uploaded some files to my dropbox'
  visit "/upload"
  attach_file(find("input[type='file']")[:id], File.join(::Rails.root, "features/data/images/berlin_wall_01.jpg") )
  attach_file(find("input[type='file']")[:id], File.join(::Rails.root, "features/data/images/berlin_wall_02.jpg") )
  attach_file(find("input[type='file']")[:id], File.join(::Rails.root, "features/data/images/date_should_be_1990.jpg") )
  attach_file(find("input[type='file']")[:id], File.join(::Rails.root, "features/data/images/date_should_be_2011-05-30.jpg") )
  find(".plupload_start").click
end

When /^I delete some fo those after the upload$/ do
  deleted_plupload_file_element_after_upload = find("#uploader_filelist li span",:text => "berlin_wall_01.jpg").find(:xpath, "../..")
  deleted_plupload_file_element_after_upload.find(".delete_plupload_entry").click
  page.driver.browser.switch_to.alert.accept
  
  deleted_dropbox_file_element_after_upload = find("#dropbox_filelist li span",:text => "berlin_wall_01.jpg").find(:xpath, "../..")
  deleted_dropbox_file_element_after_upload.find(".delete_dropbox_file").click
  page.driver.browser.switch_to.alert.accept
end

Then /^those files are deleted$/ do
  sleep(2)
  @current_user.incomplete_media_entries.each do |element|
    element.media_file.filename.should_not == "berlin_wall_01.jpg"
  end
end

Then /^only the rest of the files are available for import$/ do
  visit upload_path
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
   |Copyright|some other dude             |
   And I follow "Metadaten speichern und weiter..."
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

