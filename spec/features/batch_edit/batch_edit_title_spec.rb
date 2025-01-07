require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'batch edit title' do

  before :each do
    prepare_user

    @media_entry1 = create_media_entry('MediaEntry1')
    @media_entry2 = create_media_entry('MediaEntry2')

    @collection1 = create_collection('Collection1')
    @collection2 = create_collection('Collection2')
  end

  scenario 'show and edit published entries' do
    login
    visit '/my/content_media_entries'
    click_select_all_on_first_page
    get_action_button.click
    
    rows = get_table_rows(2)

    within rows.first do
      expect(page).to have_content(@media_entry2.media_file.filename)
      input = find('input')
      expect(input.value).to eq(@media_entry2.title)
      input.fill_in(with: 'Mauz')
    end

    within rows.second do
      expect(page).to have_content(@media_entry1.media_file.filename)
      input = find('input')
      expect(input.value).to eq(@media_entry1.title)
      input.fill_in(with: 'Murr')
    end

    click_on 'Speichern'

    expect(find('.ui-alert.success')).to have_content \
      get_expected_flash_message(total_count: 2, valid_before_count: 2, valid_count: 2)

    expect(page).to have_content 'Seite 1 von 1'
    expect(page).to have_content 'Mauz'
    expect(page).to have_content 'Murr'
  end

  scenario 'show and edit unpublished but complete entry (autopublish)' do
    media_entry = create_unpublished_entry()
    
    login
    visit '/my/unpublished_entries'
    click_select_all_on_first_page
    get_action_button.click

    rows = get_table_rows(1)

    within rows.first do
      expect(page).to have_content(media_entry.media_file.filename)
      input = find('input')
      expect(input.value).to eq('')
      input.fill_in(with: 'Garfield')
    end

    click_on 'Speichern'

    expect(find('.ui-alert.success')).to have_content \
      get_expected_flash_message(total_count: 1, valid_before_count: 0, valid_count: 1)

    visit '/my/content_media_entries'

    expect(page).to have_content 'Seite 1 von 1'
    expect(page).to have_content 'Garfield'
  end

  scenario 'show and edit incomplete entry (no autopublish)' do
    media_entry = create_unpublished_entry()
    
    AppSetting.first.update!(contexts_for_entry_validation: ['upload']) # note that that media entry factory would reset this!

    login

    visit '/my/unpublished_entries'
    click_select_all_on_first_page
    get_action_button.click

    rows = get_table_rows(1)

    within rows.first do
      expect(page).to have_content(media_entry.media_file.filename)
      input = find('input')
      expect(input.value).to eq('')
      input.fill_in(with: 'Garfield')
    end

    click_on 'Speichern'

    expect(find('.ui-alert.success')).to have_content \
      get_expected_flash_message(total_count: 1, valid_before_count: 0, valid_count: 0)

    expect(page).to have_content 'Unvollständige Medieneinträge'
    expect(page).to have_content 'Seite 1 von 1'
    expect(page).to have_content 'Garfield'
  end

  scenario 'show and edit incomplete entry, with default text filling (so autopublish works)' do
    media_entry = create_unpublished_entry()

    AppSetting.first.update!(contexts_for_entry_validation: ['upload']) # note that that media entry factory would reset this!
    AppSetting.first.update!(copyright_notice_default_text: 'copyleft')

    login

    visit '/my/unpublished_entries'
    click_select_all_on_first_page
    get_action_button.click

    rows = get_table_rows(1)

    within rows.first do
      expect(page).to have_content(media_entry.media_file.filename)
      input = find('input')
      expect(input.value).to eq('')
      input.fill_in(with: 'Garfield')
    end

    click_on 'Speichern'

    expect(find('.ui-alert.success')).to have_content \
      get_expected_flash_message(total_count: 1, valid_before_count: 0, valid_count: 1)

    visit '/my/content_media_entries'

    expect(page).to have_content 'Seite 1 von 1'
    expect(page).to have_content 'Garfield'

    click_on('Garfield')

    expect(page).to have_content 'copyleft'
  end

  def create_unpublished_entry
    media_entry = FactoryBot.create(
      :media_entry,
      get_metadata_and_previews: true,
      responsible_user: @user,
      creator: @user,
      is_published: false)
    FactoryBot.create(
      :media_file_for_image,
      media_entry: media_entry)
    media_entry
  end

  def get_action_button
    menu_text = I18n.t('resources_box_batch_actions_menu_title', raise: false)
    action_text = I18n.t('resources_box_batch_actions_edit_title')
    within('.ui-filterbar') do
      dropdown_menu_and_get(menu_text, action_text)
    end
  end

  def get_table_rows(expected_count)
    rows = find('.modal').find('table').find('tbody').all('tr').map { |tr| tr }
    expect(rows.length).to eq(expected_count)
    rows
  end

  def get_expected_flash_message(total_count: 0, valid_before_count: 0, valid_count: 0)
    text = "Alle #{total_count} Medieneinträge wurden gespeichert.\n" \
      + "(#{valid_count} haben ausgefüllte Pflichtfelder, " \
      + "#{valid_before_count} hatten bereits ausgefüllte Pflichtfelder, " \
      + "#{total_count - valid_count} haben fehlende Pflichtangaben)"
  end

end
