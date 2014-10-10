require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'import', 'shared.rb')

feature 'Import' do
  include Features::Import::Shared

  background do
    sign_in_as 'Normin'
  end

  scenario 'Canceling import preservers import files', browser: :firefox do
    remember_resources

    click_on_text 'Medien importieren'
    assert_exact_url_path '/import'
    attach_test_file 'images/berlin_wall_01.jpg'
    start_uploading
    expect_import_permissions_page
    click_link 'Abbrechen'
    assert_exact_url_path '/my'
    click_on_text 'Medien importieren'
    expect_file_in_import_list 'berlin_wall_01.jpg'
  end

  scenario 'Deleting files during the import', browser: :firefox do
    remove_media_entries_with_filename_matching 'berlin'
    remove_incomplete_media_entries_with_filename_matching 'berlin'

    remember_resources

    click_on_text 'Medien importieren'
    assert_exact_url_path '/import'
    attach_test_file 'images/berlin_wall_01.jpg'
    attach_test_file 'images/berlin_wall_02.jpg'
    start_uploading

    expect_import_permissions_page
    visit import_path
    delete_import 'berlin_wall_01.jpg'
    expect_one_file_to_import
    click_link 'Weiter...'

    assert_exact_url_path '/import/permissions'
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

  scenario 'Importing a video creates a Zencoder job and submits it', browser: :firefox do
    expect_zencoder_setup
    remember_resources

    click_on_text 'Medien importieren'
    assert_exact_url_path '/import'
    attach_test_file 'zencoder_test.mov'
    start_uploading

    expect_import_permissions_page
    click_on_text 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'

    fill_meta_key_field_with 'Zencoder Movie', 'title'
    fill_meta_key_field_with 'WTFPL', 'copyright notice'
    click_link 'Weiter...'
    wait_for_ajax
    assert_exact_url_path '/import/organize'

    click_on_text 'Import abschliessen'
    expect_new_media_entries 1
    expect_new_media_entry_with_title 'Zencoder Movie'
    expect_new_zencoder_jobs 1
    expect_most_recent_zencoder_job_with_state 'submitted'
  end

  scenario 'Importing a file with 0 bytes', browser: :firefox do
    click_on_text 'Medien importieren'
    assert_exact_url_path '/import'
    attach_test_file 'files/empty_file.mp3'
    assert_error_alert
  end

  scenario 'Setting permissions during the import', browser: :firefox do
    remember_resources

    click_on_text 'Medien importieren'
    assert_exact_url_path '/import'
    attach_test_file 'images/berlin_wall_01.jpg'
    start_uploading

    expect_import_permissions_page

    fill_in 'user', with: 'Paula, Petra'
    select_entry_from_autocomplete_list 'Paula, Petra', 'user'
    expect_checked_permission_for 'Paula, Petra', 'view'
    check_permission_for 'Paula, Petra', 'download'
    expect_checked_permission_for 'Paula, Petra', 'download'
    click_on_text 'Berechtigungen speichern'
    wait_for_ajax

    assert_exact_url_path '/import/meta_data'
    fill_meta_key_field_with 'Berlin Wall', 'title'
    fill_meta_key_field_with 'WTFPL', 'copyright notice'
    click_link 'Weiter...'
    wait_for_ajax

    assert_exact_url_path '/import/organize'
    click_on_text 'Import abschliessen'
    expect_new_media_entry_with_title 'Berlin Wall'
    expect_userpermission_for_media_entry_with_title 'Berlin Wall', 'view', 'petra'
    expect_userpermission_for_media_entry_with_title 'Berlin Wall', 'download', 'petra'
  end

  scenario 'Adding imports to a new set', browser: :firefox do
    remember_resources

    click_on_text 'Medien importieren'
    assert_exact_url_path '/import'
    attach_test_file 'images/berlin_wall_01.jpg'
    attach_test_file 'images/date_should_be_1990.jpg'
    attach_test_file 'images/date_should_be_2011-05-30.jpg'
    start_uploading

    expect_import_permissions_page

    click_on_text 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'

    fill_meta_key_field_with 'Berlin Wall', 'title'
    fill_meta_key_field_with 'WTFPL', 'copyright notice'
    click_link 'Weiter...'
    wait_for_ajax
    assert_exact_url_path '/import/organize'

    click_on_text 'Einträge zum einem Set hinzufügen'
    assert_modal_visible 'Zu Set hinzufügen/entfernen'
    within '.modal' do
      fill_in 'search_or_create_set', with: 'Import Test Set'
      click_on_text 'Neues Set erstellen'
      click_on_text 'Speicher'
    end
    assert_modal_not_visible
    click_on_text 'Import abschliessen'
    expect_new_media_entries 3
    expect_new_set_to_have_new_media_entries 'Import Test Set'
  end

  def check_permission_for(user, permission)
    within "tr[data-name='#{user}']" do
      check permission.to_s
    end
  end

  def delete_import(filename)
    accept_alert do
      within find('ul#mei_filelist li', text: filename) do
        find('a.delete_mei').click
      end
    end
  end

  def expect_checked_permission_for(user, permission)
    expect(find("tr[data-name='#{user}'] input[name='#{permission}']")).to be_checked
  end

  def expect_file_in_import_list(filename)
    expect(page).to have_css('#mei_filelist li', text: filename)
  end

  def expect_most_recent_zencoder_job_with_state(state)
    expect( ZencoderJob.reorder(created_at: :desc,id: :asc).first.state ).to eq(state)
  end

  def expect_new_set_to_have_new_media_entries(title)
    new_media_entries = MediaEntry.all - @previous_media_entries
    new_set = MediaSet.find_by_title(title)
    expect(new_set.title).to eq(title)
    expect(new_set.child_media_resources.to_a).to eq(new_media_entries)
  end

  def expect_new_zencoder_jobs(count)
    new_zencoder_jobs = ZencoderJob.all - @previous_zencoder_jobs
    expect(new_zencoder_jobs.size).to eq(count)
  end

  def expect_one_file_to_import
    all('ul#mei_filelist li', count: 1)
  end

  def expect_userpermission_for_media_entry_with_title(title, permission, login)
    new_media_entries = MediaEntry.all - @previous_media_entries
    media_entry = new_media_entries.select { |me| me.title == title }.first
    userpermission = media_entry.userpermissions.joins(:user).where("users.login = ?", login).first
    expect( userpermission.send(permission)).to be true
  end

  def expect_zencoder_setup
    Settings.add_source!( Rails.root.join('spec', 'data', 'zencoder.yml').to_s )
    Settings.reload!
  end
end
