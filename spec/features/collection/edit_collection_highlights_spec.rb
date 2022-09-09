require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'Collection: Edit Highlights' do

  describe 'Action: new' do

    scenario 'Modal dialog is shown' do
      prepare_data
      login
      open_collection
      open_dialog(true)
      # rows = get_table_rows(5)
      rows = get_table_rows(4)

      # The order is defined in:
      # Presenters::Shared::MediaResource::MediaResources
      # It says its by "created_at DESC". So the last entry appears first.
      check_row(rows, @media_entry1, false)
      check_row(rows, @media_entry2, false)
      check_row(rows, @media_entry3, false)
      check_row(rows, @collection1, false)
      expect(@collection.highlighted_media_entries.length).to eq(0)
    end

    scenario 'Select and save highlights' do
      prepare_data
      login
      open_collection

      check_show_highlights(false, [])

      open_dialog(true)
      # rows = get_table_rows(5)
      rows = get_table_rows(4)
      check_row(rows, @media_entry1, false)
      check_row(rows, @media_entry2, false)
      check_row(rows, @media_entry3, false)
      check_row(rows, @collection1, false)
      expect(@collection.highlighted_media_entries.length).to eq(0)

      click_row(rows, @media_entry2)
      click_row(rows, @collection1)

      click_save

      check_show_highlights(true, [@media_entry2, @collection1])

      @collection = Collection.find(@collection.id)
      check_media_entries([@media_entry2])
      check_collections([@collection1])

      open_dialog(true)
      # rows = get_table_rows(5)
      rows = get_table_rows(4)

      check_row(rows, @media_entry1, false)
      check_row(rows, @media_entry2, true)
      check_row(rows, @media_entry3, false)
      check_row(rows, @collection1, true)

      click_row(rows, @media_entry2)
      click_row(rows, @collection1)

      click_save
      @collection = Collection.find(@collection.id)
      check_media_entries([])
      check_collections([])

      open_collection
    end

    scenario 'private media entry in public collection' do
      prepare_user
      @media_entry = create_media_entry('MediaEntry')
      @collection = create_collection('Collection')
      @collection.media_entries << @media_entry
      login
      open_collection

      check_show_highlights(false, [])
      open_dialog(true)
      rows = get_table_rows(1)
      click_row(rows, @media_entry)
      check_row(rows, @media_entry, true)

      click_save
      @collection = Collection.find(@collection.id)
      check_show_highlights(true, [@media_entry])
      check_media_entries([@media_entry])
      check_collections([])

      @media_entry.get_metadata_and_previews = false
      @media_entry.save

      @media_entry.reload
      @collection.reload

      logout

      open_collection

      check_show_highlights(false, [])
      check_media_entries([@media_entry])
      check_collections([])
    end

    scenario 'do not show not viewable entries in edit dialog' do

      prepare_user
      @media_entry = create_media_entry('MediaEntry')
      @collection = create_collection('Collection')
      @collection.media_entries << @media_entry

      @media_entry.get_metadata_and_previews = false
      @media_entry.responsible_user = FactoryGirl.create(:user)
      @media_entry.save
      @media_entry.reload
      @collection.reload

      login
      open_collection
      open_dialog(false)
    end
  end

  private

  def check_show_highlights(show, resources)
    titles = all(
      '.ui-toolbar-header',
      text: I18n.t(:collection_highlighted_contents))

    if show
      expect(titles.length).to eq(1)

      box = find('.ui-featured-entries')
      images = box.all('.ui-tile__image')
      expect(images.length).to eq(resources.length)

      within(box) do
        resources.each do |resource|
          expect(page).to have_content(resource.title)
        end
      end

    else
      expect(titles.length).to eq(0)
    end
  end

  def check_shared(collection_relation, resources)
    expect(collection_relation.length).to eq(resources.length)
    resources.each do |resource|
      expect(collection_relation.include?(resource))
    end
  end

  def check_media_entries(media_entries)
    check_shared(@collection.highlighted_media_entries, media_entries)
  end

  def check_collections(collections)
    check_shared(@collection.highlighted_collections, collections)
  end

  def get_table_rows(expected_count)
    rows = find('.modal').find('table').find('tbody').all('tr').map { |tr| tr }
    expect(rows.length).to eq(expected_count)
    rows
  end

  def click_row(rows, resource)
    row = get_row_by_resource(rows, resource)
    row.find('input[name="resource_selections[][selected]"]').click
  end

  def get_row_by_resource(rows, resource)
    rows.each do |row|
      cell = row.all('td')[1]
      text = cell.find('span').text
      if text == resource.title
        return row
      end
    end
    nil
  end

  def check_row(rows, resource, checked)
    row = get_row_by_resource(rows, resource)

    id_input = row.find('input[name="resource_selections[][id]"]', visible: false)
    expect(id_input[:value]).to eq(resource.id)

    check_input = row.find('input[name="resource_selections[][selected]"]')
    expected = checked ? 'true' : nil
    expect(check_input[:checked]).to eq(expected)
  end

  def open_collection
    visit collection_path(@collection)
  end

  def find_dropdown
    find('.ui-body-title-actions').find('.ui-dropdown')
  end

  def open_dialog(has_content)
    find_dropdown.click
    find_dropdown.find('i.icon-highlight').find(:xpath, './..').click
    check_on_dialog(has_content)
  end

  def click_save
    find('.modal').find('button', text: 'Auswahl speichern').click
  end

  def check_on_dialog(has_content)
    expect(current_path).to eq highlights_edit_collection_path(@collection)
    expect(page).to have_content 'Inhalte hervorheben'
    expect(page).to have_content 'Auswahl speichern' if has_content
    expect(page).to have_content 'Abbrechen'

    if has_content
      expect(page).to have_selector('.modal table tbody tr')
    else
      expect(page).to have_no_selector('.modal table tbody tr')
    end
  end

  def prepare_data
    prepare_user

    @media_entry1 = create_media_entry('MediaEntry1')
    @media_entry2 = create_media_entry('MediaEntry2')
    @media_entry3 = create_media_entry('MediaEntry3')
    @collection1 = create_collection('Collection1')
    @collection = create_collection('Collection')
    @collection.media_entries << @media_entry1
    @collection.media_entries << @media_entry2
    @collection.media_entries << @media_entry3
    @collection.collections << @collection1
  end

end
