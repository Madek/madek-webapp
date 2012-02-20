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
  @media_entry_incomplete.userpermissions.empty?.should be_true
  @media_entry_incomplete.grouppermissions.empty?.should be_true
  visit "/upload"
  step "I follow \"weiter...\""
  step 'I type "Adam" into the "user" autocomplete field'
  step 'I pick "Admin, Adam" from the autocomplete field'
  step 'I give "view" permission to "Admin, Adam" without saving'
  step "I follow \"Berechtigungen speichern und weiter...\""
  @media_entry_incomplete.userpermissions.reload.empty?.should be_false
  @media_entry_incomplete.userpermissions.first.view.should == true
end



Then /^I add the media entry to a set called "([^"]*)"$/ do |arg1|
  @media_entry_incomplete.media_sets.empty?.should be_true
  visit "/upload/set_media_sets"
  step 'I follow "Einträge zu einem Set hinzufügen"'
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
  visit "/upload"
  path = File.join(::Rails.root, "features/data/files/file_biger_then_1_4_GB.mov") 
  attach_file(find("input[type='file']")[:id], path)
end

Then /^the system gives me a warning telling me it's impossible to upload so much through the browser$/ do
  find(".dialog").should have_content "Die ausgewählte Datei war zu gross"
end

Then /^the warning includes instructions for an FTP upload$/ do
  find(".dialog").should have_content "FTP"
end

When /^I have uploaded some files to my dropbox$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I start a new upload process$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I can choose files from my dropbox instead of uploading them through the browser$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I have uploaded a directory with some files to my dropbox$/ do
  pending # express the regexp above with the code you wish you had
end

When /^that directory contains another directory with files$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I can choose all the files from all those directories from my dropbox instead of uploading them through the browser$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I have started uploading some files$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I cancel the upload$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the uploaded files are deleted$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the upload process ends$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I have uploaded some files$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I delete some of those files during the import$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^those files are deleted$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^only the rest of the files are imported$/ do
  pending # express the regexp above with the code you wish you had
end
