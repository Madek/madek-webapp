require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Collection: Edit Highlights' do

  describe 'Action: new' do

    scenario 'Modal dialog is shown', browser: :firefox do
      login
      open_dialog
      rows = get_table_rows(5)

      # The order is defined in:
      # Presenters::Shared::MediaResource::MediaResources
      # It says its by "created_at DESC". So the last entry appears first.
      check_row(rows, @media_entry1, false)
      check_row(rows, @media_entry2, false)
      check_row(rows, @media_entry3, false)
      check_row(rows, @collection1, false)
      check_row(rows, @filter_set1, false)
      expect(@collection.highlighted_media_entries.length).to eq(0)
    end

    scenario 'Select and save highlights', browser: :firefox do
      login
      open_dialog
      rows = get_table_rows(5)
      check_row(rows, @media_entry1, false)
      check_row(rows, @media_entry2, false)
      check_row(rows, @media_entry3, false)
      check_row(rows, @collection1, false)
      check_row(rows, @filter_set1, false)
      expect(@collection.highlighted_media_entries.length).to eq(0)

      click_row(rows, @media_entry2)
      click_row(rows, @collection1)
      click_row(rows, @filter_set1)

      click_save
      @collection = Collection.find(@collection.id)
      check_media_entries([@media_entry2])
      check_collections([@collection1])
      check_filter_sets([@filter_set1])

      open_dialog
      rows = get_table_rows(5)
      check_row(rows, @media_entry1, false)
      check_row(rows, @media_entry2, true)
      check_row(rows, @media_entry3, false)
      check_row(rows, @collection1, true)
      check_row(rows, @filter_set1, true)

      click_row(rows, @media_entry2)
      click_row(rows, @collection1)
      click_row(rows, @filter_set1)

      click_save
      @collection = Collection.find(@collection.id)
      check_media_entries([])
      check_collections([])
      check_filter_sets([])

    end

  end

  private

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

  def check_filter_sets(filter_sets)
    check_shared(@collection.highlighted_filter_sets, filter_sets)
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

  def open_dialog
    visit collection_path(@collection)
    find('i.icon-highlight').find(:xpath, './..').click
    check_on_dialog
  end

  def click_save
    find('.modal').find('button', text: 'Auswahl speichern').click
  end

  def check_on_dialog
    expect(current_path).to eq highlights_edit_collection_path(@collection)
    expect(page).to have_content 'Inhalte hervorheben'
    expect(page).to have_content 'Auswahl speichern'
    expect(page).to have_content 'Abbrechen'
  end

  def login
    prepare_data
    sign_in_as @login, @password
  end

  def prepare_data
    @login = 'user'
    @password = '1234'

    @user = FactoryGirl.create(:user, login: @login, password: @password)
    @media_entry1 = create_media_entry('MediaEntry1')
    @media_entry2 = create_media_entry('MediaEntry2')
    @media_entry3 = create_media_entry('MediaEntry3')
    @collection1 = create_collection('Collection1')
    @filter_set1 = create_filter_set('FilterSet1')
    @collection = create_collection('Collection')
    @collection.media_entries << @media_entry1
    @collection.media_entries << @media_entry2
    @collection.media_entries << @media_entry3
    @collection.collections << @collection1
    @collection.filter_sets << @filter_set1
  end

  def create_media_entry(title)
    media_entry = FactoryGirl.create(
      :media_entry,
      responsible_user: @user,
      creator: @user)
    FactoryGirl.create(
      :media_file_for_image,
      media_entry: media_entry)
    MetaDatum::Text.create!(
      media_entry: media_entry,
      string: title,
      meta_key: meta_key_title,
      created_by: @user)
    media_entry
  end

  def create_collection(title)
    collection = Collection.create!(
      get_metadata_and_previews: true,
      responsible_user: @user,
      creator: @user)
    MetaDatum::Text.create!(
      collection: collection,
      string: title,
      meta_key: meta_key_title,
      created_by: @user)
    collection
  end

  def create_filter_set(title)
    filter_set = FactoryGirl.create(
      :filter_set,
      responsible_user: @user,
      creator: @user)
    MetaDatum::Text.create!(
      filter_set: filter_set,
      string: title,
      meta_key: meta_key_title,
      created_by: @user)
    filter_set
  end

  def meta_key_title
    MetaKey.find_by(id: 'madek_core:title')
  end

end
