require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'Collection: Edit Cover' do

  describe 'Action: new' do

    scenario 'Modal dialog is shown' do
      prepare_data
      login
      open_dialog
      rows = get_table_rows
      expect(rows.length).to eq(2)

      # The order is defined in:
      # Presenters::Shared::MediaResource::MediaResources
      # It says its by "created_at DESC". So the second entry appears first.
      check_row(rows[0], @media_entry2, false)
      check_row(rows[1], @media_entry1, false)
      expect(@collection.cover).to eq(nil)
    end

    scenario 'Select and save a cover' do
      prepare_data
      login
      open_dialog
      rows = get_table_rows
      expect(rows.length).to eq(2)
      check_row(rows[0], @media_entry2, false)
      check_row(rows[1], @media_entry1, false)
      expect(@collection.cover).to eq(nil)

      select_row(rows[1])
      click_save
      expect(@collection.cover.id).to eq(@media_entry1.id)

      open_dialog
      rows = get_table_rows
      expect(rows.length).to eq(2)
      check_row(rows[0], @media_entry2, false)
      check_row(rows[1], @media_entry1, true)
    end
  end

  private

  def get_table_rows
    find('.modal').find('table').find('tbody').all('tr').map { |tr| tr }
  end

  def get_radio(row)
    row.find('input[name="selected_resource"]')
  end

  def select_row(row)
    get_radio(row).click
  end

  def check_row(row, media_entry, checked)
    radio = get_radio(row)
    expect(radio[:value]).to eq(media_entry.id)
    is_checked = radio[:checked]
    expected = checked ? 'true' : nil
    expect(is_checked).to eq(expected)
  end

  def open_dialog
    visit collection_path(@collection)
    find('i.icon-cover').find(:xpath, './..').click
    check_on_dialog
  end

  def click_save
    find('.modal').find('button', text: 'Auswahl speichern').click
  end

  def check_on_dialog
    expect(current_path).to eq cover_edit_collection_path(@collection)
    expect(page).to have_content 'Titelbild für Set festlegen'
    expect(page).to have_content 'Auswahl speichern'
    expect(page).to have_content 'Abbrechen'
  end

  def prepare_data
    prepare_user

    @media_entry1 = create_media_entry('')
    @media_entry2 = create_media_entry('')
    @collection = create_collection('')
    @collection.media_entries << @media_entry1
    @collection.media_entries << @media_entry2
  end

end
