require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'import', 'shared.rb')

feature 'Importing files with metadata and setting metadata' do
  include Features::Import::Shared

  background do
    @current_user = sign_in_as 'Normin'
    remember_resources

    click_on_text 'Medien importieren'
    assert_exact_url_path '/import'
  end

  scenario 'Using the sequential metadata editor', browser: :firefox do
    attach_test_file 'images/berlin_wall_01.jpg'
    attach_test_file 'images/berlin_wall_02.jpg'
    start_uploading
    expect_import_permissions_page

    click_on_text 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'
    fill_meta_key_field_with 'Berlin Wall 01', 'title'
    fill_meta_key_field_with 'WTFPL', 'copyright notice'
    click_on_text 'Nächster Eintrag'
    fill_meta_key_field_with 'Berlin Wall 02', 'title'
    fill_meta_key_field_with 'WTFPL', 'copyright notice'
    click_link 'Weiter...'
    wait_for_ajax
    assert_exact_url_path '/import/organize'

    click_on_text 'Import abschliessen'
    expect_new_media_entries 2
    expect_new_media_entry_with_title 'Berlin Wall 01'
    expect_new_media_entry_with_title 'Berlin Wall 02'
  end

  scenario 'Filtering entries with missing metadata in the sequential metadata editor', browser: :firefox do
    attach_test_file 'images/berlin_wall_01.jpg'
    attach_test_file 'images/berlin_wall_02.jpg'
    attach_test_file 'images/date_should_be_1990.jpg'
    attach_test_file 'images/date_should_be_2011-05-30.jpg'
    start_uploading
    expect_import_permissions_page

    click_on_text 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'
    expect_files_with_missing_meta_data 2
    show_only_files_with_missing_meta_data
    expect_only_files_with_missing_meta_data 2

    fill_meta_key_field_with 'Berlin Wall 01', 'title'
    fill_meta_key_field_with 'WTFPL', 'copyright notice'
    click_on_text 'Nächster Eintrag'
    fill_meta_key_field_with 'Berlin Wall 02', 'title'
    fill_meta_key_field_with 'WTFPL', 'copyright notice'
    click_link 'Weiter...'
    wait_for_ajax
    assert_exact_url_path '/import/organize'

    click_on_text 'Import abschliessen'
    expect_new_media_entries 4
    expect_new_media_entry_with_title 'Berlin Wall 01'
    expect_new_media_entry_with_title 'Berlin Wall 02'
  end

  scenario 'Importing an image that has MAdeK title and date information (specific date) in its EXIF/IPTC metadata',
    browser: :firefox do
    attach_test_file 'images/date_should_be_2011-05-30.jpg'
    start_uploading
    expect_import_permissions_page

    click_on_text 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'
    click_link 'Weiter...'
    wait_for_ajax
    assert_exact_url_path '/import/organize'

    click_on_text 'Import abschliessen'
    expect_new_media_entries 1
    expect_new_media_entry_with_title 'Grumpy Cat'

    visit_page_of_the_last_added_media_entry
    expect(page).to have_content('30.05.2011')
    expect(page).to have_content('Grumpy Cat')
  end

  scenario 'Importing an image that has MAdeK title and date information (specific date) in its EXIF/IPTC metadata',
    browser: :firefox do
    attach_test_file 'images/date_should_be_from_to_may.jpg'
    start_uploading
    expect_import_permissions_page

    click_on_text 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'
    click_link 'Weiter...'
    wait_for_ajax
    assert_exact_url_path '/import/organize'

    click_on_text 'Import abschliessen'
    expect_new_media_entries 1

    visit_page_of_the_last_added_media_entry
    expect(page).to have_content('01.05.2011 - 31.05.2011')
    expect(page).to have_content('Frau-Sein')
    expect(page).to have_content('Buser, Monika')
    expect(page).to have_content('Diplomarbeit')
    # Only one out of keyword seems to be imported; is it an array or umlaut problem?
    # or something else
    expect(page).to have_content('Porträt')
    expect(page).to have_content('Selbstporträt')
    expect(page).to have_content('Schweiz')
  end

  scenario 'Importing an image that has MAdeK title and date information (specific date) in its EXIF/IPTC metadata',
    browser: :firefox do
    attach_test_file 'images/date_should_be_1990.jpg'
    start_uploading
    expect_import_permissions_page

    click_on_text 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'
    click_link 'Weiter...'
    wait_for_ajax
    assert_exact_url_path '/import/organize'

    click_on_text 'Import abschliessen'
    expect_new_media_entries 1

    visit_page_of_the_last_added_media_entry
    expect(page).to have_content('1990')
    expect(page).to have_content('Frau-Sein')
    expect(page).to have_content('Buser, Monika')
    expect(page).to have_content('Diplomarbeit')
    expect(page).to have_content('Porträt')
    expect(page).to have_content('Selbstporträt')
    expect(page).to have_content('Schweiz')
  end

  scenario 'Importing images and setting some metadata', browser: :firefox do
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
    click_on_text 'Import abschliessen'

    expect_new_media_entries 3
    expect_new_media_entry_with_title 'Berlin Wall'
  end

  scenario 'Highlighting and enforcing required meta fields', browser: :firefox do
    attach_test_file 'images/berlin_wall_01.jpg'
    start_uploading
    expect_import_permissions_page

    click_on_text 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'
    expect_required_meta_key_value 'title'
    expect_required_meta_key_value 'copyright notice'
    click_link 'Weiter...'
    wait_for_ajax

    assert_exact_url_path '/import/meta_data'
    assert_error_alert
    fill_meta_key_field_with 'Berlin Wall', 'title'
    fill_meta_key_field_with 'WTFPL', 'copyright notice'
    click_link 'Weiter...'
    wait_for_ajax

    assert_exact_url_path '/import/organize'
  end

  def expect_files_with_missing_meta_data(count)
    wait_for_ajax
    expect(all('ul.ui-resources li.ui-invalid').size).to eq(count)
  end

  def expect_only_files_with_missing_meta_data(count)
    expect(all('ul.ui-resources li').size).to eq(count)
  end

  def expect_required_meta_key_value(meta_key_id)
    expect(page).to have_css("fieldset.error[data-meta-key='#{meta_key_id}']")
  end

  def show_only_files_with_missing_meta_data
    check 'display-only-invalid-resources'
  end

  def visit_page_of_the_last_added_media_entry
    visit media_entry_path(MediaEntry.reorder(created_at: :desc, id: :asc).first)
  end
end
