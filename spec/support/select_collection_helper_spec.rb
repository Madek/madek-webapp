require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

module SelectCollectionHelper

  def scenario_modal_dialog_is_shown
    login
    open_dialog
  end

  def scenario_modal_dialog_cancel
    login
    open_dialog
    cancel
    expect(current_path).to eq resource_path
  end

  def scenario_initial_sets_are_equal_to_parent_collections
    login
    open_dialog
    check_set('Collection 1', true, true)
    check_set('Collection 2', false, false)
    check_set('Collection 3', false, false)
    check_set('Collection 4', false, false)
  end

  def scenario_search_for_collections
    login
    open_dialog
    search_collection('C')
    check_on_dialog
    check_set('Collection 1', true, true)
    check_set('Collection 2', true, false)
    check_set('Collection 3', true, false)
    check_set('Collection 4', false, false)
  end

  def scenario_save_no_checkboxes_visible
    login
    open_dialog
    search_collection('<NOT AVAILABLE>')
    check_on_dialog
    check_set('Collection 1', false, false)
    check_set('Collection 2', false, false)
    check_set('Collection 3', false, false)
    check_set('Collection 4', false, false)
    click_save

    expect(current_path).to eq resource_path
    expect(page).to have_content(expected_flash_message(0, 0))

    collection_contains_resource(@collection1, true)
    collection_contains_resource(@collection2, false)
    collection_contains_resource(@collection3, false)
    collection_contains_resource(@collection4, false)
  end

  def select_checkboxes
    checkbox1 = checkbox_by_collection('Collection 1')
    checkbox2 = checkbox_by_collection('Collection 2')
    checkbox3 = checkbox_by_collection('Collection 3')
    checkbox1.set(false)
    checkbox2.set(true)
    checkbox3.set(true)
  end

  def verify_shown_collections
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

  def scenario_add_and_remove_a_collection
    login
    open_dialog

    search_collection('C')
    check_on_dialog

    select_checkboxes

    click_save

    expect(current_path).to eq resource_path
    expect(page).to have_content(expected_flash_message(1, 2))

    collection_contains_resource(@collection1, false)
    collection_contains_resource(@collection2, true)
    collection_contains_resource(@collection3, true)
    collection_contains_resource(@collection4, false)

    open_dialog
    check_on_dialog

    verify_shown_collections
  end

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

    child_resources(@collection1) << @resource
  end

  def prepare_data
    @login = 'user'
    @password = '1234'

    @user = FactoryGirl.create(:user, login: @login, password: @password)

    @other = FactoryGirl.create(:user, login: 'login', password: 'password')

    prepare_resource

    prepare_collections
  end

  def login
    prepare_data
    sign_in_as @login, @password
  end

  def open_media_entry
    visit resource_path
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
    title = I18n.t(:resource_action_select_collection, raise: false)
    find('.ui-body-title-actions').find('.button[title="' + title + '"]').click
  end

  def check_on_dialog
    expect(current_path).to eq select_collection_path
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
      within '.modal' do
        expect(page).to have_no_content(name)
      end
    end
  end

  def search_collection(search_term)
    find('input[name=search_term]').set(search_term)
    find('button', text: 'Suchen').click
  end

  def collection_contains_resource(collection, contains)
    expect(child_resources(collection).include?(@resource)).to eq(contains)
  end

  def open_dialog
    open_media_entry
    click_select_collections
    check_on_dialog
  end

end
