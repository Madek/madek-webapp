# -*- encoding : utf-8 -*-

Given /^the current user has a dropbox$/ do
  FileUtils.mkdir_p File.join(AppSettings.dropbox_root_dir, @current_user.dropbox_dir_name)
end

When /^I open the dropbox informations dialog$/ do
  find(".open_dropbox_dialog").click
  step 'I wait for the dialog to appear'
end

When /^I create a dropbox$/ do
  step 'I click on the link "Dropbox erstellen" inside of the dialog'
end

Then /^the dropbox was created for me$/ do
  expect( @current_user.dropbox_dir_name.blank? ).to be_false
end

Then /^I can see instructions for an FTP import$/ do
  step %Q{I can see the text "#{@current_user.dropbox_dir_name}"}
  step %Q{I can see the text "#{AppSettings.ftp_dropbox_server}"}
  step %Q{I can see the text "#{AppSettings.ftp_dropbox_user}"}
  step %Q{I can see the text "#{AppSettings.ftp_dropbox_password}"}
end

When /^I try to import a file with a file size greater than 1.4 GB$/ do
  begin
    path = File.join(::Rails.root, "tmp/file_biger_then_1_4_GB.mov") 
    `dd if=/dev/zero of=#{path} count=3000000` 
    visit import_path
    attach_file(find("input[type='file']")[:id], path)
  ensure
    File.delete path
  end
end

When /^I upload some files to my dropbox$/ do
  @dir = "/ftp_test"
  dropbox_test_dir = File.join(AppSettings.dropbox_root_dir, @current_user.dropbox_dir_name, @dir)
  FileUtils.mkdir_p dropbox_test_dir
  @file_paths = Dir.glob("#{Rails.root}/features/data/images/*.jpg")
  FileUtils.cp_r(@file_paths, dropbox_test_dir)
end

Then /^those files are getting imported during the upload$/ do
  visit import_path
  @file_paths.each do |file_path|
    matcher = /#{@dir}\/.*?#{Pathname.new(file_path).basename.to_s}.*?\(Dropbox\)/
    find("#dropbox_filelist .plupload_dropbox.plupload_transfer", :text => matcher)
  end
  step 'I click on the link "Weiter…"'
  wait_until(50){all("#dropbox_filelist").size == 0}
  expect(@current_user.incomplete_media_entries.size).to eq @file_paths.size
end