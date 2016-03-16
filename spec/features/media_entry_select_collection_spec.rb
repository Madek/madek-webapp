require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MediaEntry: Select Collection' do

  describe 'Action: show' do
    scenario 'Modal dialog is shown', browser: :firefox do
      login
      open_dialog
    end

    scenario 'Modal dialog cancel', browser: :firefox do
      login
      open_dialog
      cancel
      expect(current_path).to eq media_entry_path(@media_entry)
    end

    scenario 'Initial sets are equal to parent collections', browser: :firefox do
      login
      open_dialog
      check_set('Collection 1', true, true)
      check_set('Collection 2', false, false)
      check_set('Collection 3', false, false)
      check_set('Collection 4', false, false)
    end

    scenario 'Search for collections', browser: :firefox do
      login
      open_dialog
      find('input[name=search_term]').set('C')
      find('button', text: 'Suchen').click
      check_on_dialog
      check_set('Collection 1', true, true)
      check_set('Collection 2', true, false)
      check_set('Collection 3', true, false)
      check_set('Collection 4', false, false)
    end
  end

  describe 'Action: create' do

    scenario 'Add and remove a collection', browser: :firefox do
      login
      open_dialog

      search_collection('C')
      check_on_dialog

      checkbox1 = checkbox_by_collection('Collection 1')
      checkbox2 = checkbox_by_collection('Collection 2')
      checkbox3 = checkbox_by_collection('Collection 3')
      checkbox1.set(false)
      checkbox2.set(true)
      checkbox3.set(true)

      click_save

      expect(current_path).to eq media_entry_path(@media_entry)
      expect(page).to have_content(
        'Removed entry from 1 sets. Added entry to 2 sets.')

      collection_contains_media_entry(@collection1, false)
      collection_contains_media_entry(@collection2, true)
      collection_contains_media_entry(@collection3, true)
      collection_contains_media_entry(@collection4, false)

      open_dialog
      check_on_dialog
      check_set('Collection 1', false, false)
      check_set('Collection 2', true, true)
      check_set('Collection 3', true, true)
      check_set('Collection 4', false, false)

      search_collection('C')

      check_set('Collection 1', true, false)
      check_set('Collection 2', true, true)
      check_set('Collection 3', true, true)
      check_set('Collection 4', false, false)

    end
  end

  private

  def meta_key_title
    MetaKey.find_by(id: 'madek_core:title')
  end

  def prepare_collection(title, is_responsible, is_allowed)
    creator = is_responsible ? @user : @other

    collection = Collection.create!(
      get_metadata_and_previews: true,
      responsible_user: creator,
      creator: creator)
    MetaDatum::Text.create!(
      collection: collection,
      string: title,
      meta_key: meta_key_title,
      created_by: creator)

    if is_allowed
      FactoryGirl.create(
        :collection_user_permission,
        user: @user,
        updator: @user,
        collection: collection,
        get_metadata_and_previews: true,
        edit_metadata_and_relations: true)
    end

    collection
  end

  def prepare_collections
    @collection1 = prepare_collection('Collection 1', true, true)
    @collection2 = prepare_collection('Collection 2', true, true)
    @collection3 = prepare_collection('Collection 3', false, true)
    @collection4 = prepare_collection('Collection 4', false, false)

    @collection1.media_entries << @media_entry
  end

  def prepare_data
    @login = 'user'
    @password = '1234'

    @user = FactoryGirl.create(:user, login: @login, password: @password)

    @other = FactoryGirl.create(:user, login: 'login', password: 'password')

    @media_entry = FactoryGirl.create(
      :media_entry,
      responsible_user: @user,
      creator: @user)

    @media_file = FactoryGirl.create(
      :media_file_for_image,
      media_entry: @media_entry)

    FactoryGirl.create(
      :meta_datum_text,
      created_by: @user,
      meta_key: meta_key_title,
      media_entry: @media_entry,
      value: 'Medien Eintrag 1')

    prepare_collections
  end

  def reload_collection(collection)
    Collection.find(collection.id)
  end

  def login
    prepare_data
    sign_in_as @login, @password
  end

  def open_media_entry
    visit media_entry_path(@media_entry)
  end

  def cancel
    within '.modal' do
      find('a', text: 'Abbrechen', visible: false).click
    end
  end

  def click_save
    within '.modal' do
      find('button', text: 'Speichern', visible: false).click
    end
  end

  def click_select_collections
    find('i.icon-move').find(:xpath, './..').click
  end

  def check_on_dialog
    expect(current_path).to eq select_collection_media_entry_path(@media_entry)
    expect(page).to have_content 'Zu Set hinzufügen/entfernen'
    expect(page).to have_content 'Speichern'
    expect(page).to have_content 'Abbrechen'
  end

  def checkbox_by_collection(name)
    within '.ui-modal-body' do
      label = find('span', text: name)
      parent = label.find(:xpath, './..')
      parent.find('input.ui-set-list-input')
    end
  end

  def check_set(name, is_visible, is_checked)
    if is_visible
      expect(page).to have_content(name)
      checkbox = checkbox_by_collection(name)
      if is_checked
        expect(checkbox['checked']).to eq('true')
      else
        expect(checkbox['checked']).to eq(nil)
      end
    else
      expect(page).to have_no_content(name)
    end
  end

  def search_collection(search_term)
    find('input[name=search_term]').set(search_term)
    find('button', text: 'Suchen').click
  end

  def collection_contains_media_entry(collection, contains)
    expect(collection.media_entries.include?(@media_entry)).to eq(contains)
  end

  def open_dialog
    open_media_entry
    click_select_collections
    check_on_dialog
  end

end
