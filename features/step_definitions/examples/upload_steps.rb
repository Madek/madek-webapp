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

=begin
    visit "/"

    # The upload itself
    click_link("Hochladen")
    click_link("Basic Uploader")
    attach_file("uploaded_data[]", Rails.root + "features/data/images/berlin_wall_01.jpg")
    click_button("Ausgewählte Medien hochladen und weiter…")
    wait_for_css_element("#submit_to_3") # This is the "Einstellungen speichern..." button
    click_button("Einstellungen speichern und weiter…")

    # Entering metadata

    fill_in_for_media_entry_number(1, { "Titel"     => title,
                                        "Copyright" => 'some dude' })

    click_button("Metadaten speichern und weiter…")
    click_link_or_button("Weiter ohne Hinzufügen zu einem Set…")

    visit "/"
   
    page.should have_content(title)
=end  
  
  @path = "features/data/images/berlin_wall_01.jpg"
  step 'I upload the file "#{@path}" relative to the Rails directory'
end

Then /^the file is attached to a media entry$/ do
  @media_entry_incomplete.media_file.valid?.should be_true
  @media_entry_incomplete.media_file.persisted?.should be_true
  @media_entry_incomplete.media_file.filename.should == File.basename("#{Rails.root}/#{@path}")  
end

Then /^I can set the permissions for the media entry during the upload process$/ do
  @media_entry_incomplete.userpermissions.empty?.should be_true
  @media_entry_incomplete.grouppermissions.empty?.should be_true
end

When /^I upload files totalling more than (\d+)\.(\d+) GB$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^the system gives me a warning telling me it's impossible to upload so much through the browser$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the warning includes instructions for an FTP upload$/ do
  pending # express the regexp above with the code you wish you had
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