require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'import', 'shared.rb')

feature 'Import via Dropbox' do
  include Features::Import::Shared

  background do
    @current_user = sign_in_as 'Normin'
  end

  scenario 'Creating my dropbox', browser: :firefox do
    expect_dropbox_setup
    remove_user_dropbox
    visit '/import'
    find('.open_dropbox_dialog').click
    assert_modal_visible 'FTP Dropbox'
    click_primary_action_of_modal
    expect_created_dropbox
    expect_instructions_for_ftp_upload
  end

  scenario 'Importing large files', browser: :firefox do
    create_dropbox_for_user
    try_to_import_large_file
    assert_error_alert
    expect_instructions_for_ftp_upload
  end

  scenario 'Importing via dropbox', browser: :firefox do
    create_dropbox_for_user
    upload_some_files_to_dropbox
    expect_files_to_be_imported_during_upload
  end

  scenario 'Deleting files during the import via dropbox', browser: :firefox do
    create_dropbox_for_user
    remember_resources
    remove_media_entries_with_filename_matching 'berlin'
    remove_incomplete_media_entries_with_filename_matching 'berlin'

    upload_file_via_dropbox 'berlin_wall_01.jpg'
    upload_file_via_dropbox 'berlin_wall_02.jpg'

    visit import_path
    delete_dropbox_import 'berlin_wall_01.jpg'
    expect_one_dropbox_import
    start_uploading(10)
    expect_import_permissions_page

    click_on_text 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'
    fill_meta_key_field_with 'Berlin Wall 01', 'title'
    fill_meta_key_field_with 'WTFPL', 'copyright notice'

    click_link 'Weiter...'
    wait_for_ajax
    assert_exact_url_path '/import/organize'

    click_on_text 'Import abschliessen'
    expect_new_media_entries 1
    expect_exactly_one_media_entry_with_filename_matching 'berlin'
    expect_no_incomplete_media_entry_with_filename_matching 'berlin'
  end

  def create_dropbox_for_user
    expect_dropbox_setup
    `rm -rf #{@current_user.dropbox_dir_path}`
    FileUtils.mkdir_p @current_user.dropbox_dir_path
  end

  def delete_dropbox_import(filename)
    accept_alert do
      within find('#dropbox_filelist li', text: filename) do
        find('a.delete_dropbox_file').click
      end
    end
  end

  def expect_created_dropbox
    expect( @current_user.dropbox_dir_name.blank? ).to be false
  end

  def expect_dropbox_setup
    expect(Settings.dropbox.root_dir).to eq( Rails.root.join("tmp").to_s )
    expect(Settings.dropbox.user).to eq( ENV['USER'] )
  end

  def expect_files_to_be_imported_during_upload
    visit import_path
    @file_paths.each do |file_path|
      matcher = /#{@dir}\/.*?#{Pathname.new(file_path).basename.to_s}.*?\(Dropbox\)/
      find('#dropbox_filelist .plupload_dropbox.plupload_transfer', text: matcher)
    end
    start_uploading(10)
    expect(@current_user.incomplete_media_entries.size).to eq( @files_to_upload )
  end

  def expect_instructions_for_ftp_upload
    within '.modal' do
      expect(page).to have_content(@current_user.dropbox_dir_name)
      expect(page).to have_content(Settings.dropbox_server)
      expect(page).to have_content(Settings.dropbox.user)
      expect(page).to have_content(Settings.dropbox.password)
    end
  end

  def expect_one_dropbox_import
    all('#dropbox_filelist li', count: 1)
  end

  def remove_user_dropbox
    if _dir = @current_user.dropbox_dir
      `rm -rf #{_dir}`
    end
  end

  def try_to_import_large_file
    path = File.join(::Rails.root, 'tmp/file_biger_then_1_4_GB.mov')
    `dd if=/dev/zero of=#{path} count=3000000`
    visit import_path
    attach_file(find("input[type='file']", visible: false)[:id], path, visible: false)
  ensure
    File.delete path
  end

  def upload_file_via_dropbox(filename)
    @files_to_upload ||= 0
    `cp #{Rails.root.join('spec', 'data', 'images', filename)} #{@current_user.dropbox_dir}`
    @files_to_upload += 1
  end

  def upload_some_files_to_dropbox
    @dir = '/ftp_test'
    dropbox_test_dir = File.join(Settings.dropbox.root_dir, @current_user.dropbox_dir_name, @dir)
    FileUtils.mkdir_p dropbox_test_dir
    @file_paths = Dir.glob("#{Rails.root}/spec/data/images/*.jpg")
    @files_to_upload = @file_paths.size
    FileUtils.cp_r(@file_paths, dropbox_test_dir)
  end
end
