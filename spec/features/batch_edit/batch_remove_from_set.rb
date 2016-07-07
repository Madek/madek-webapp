require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/meta_data_helper_spec'
include MetaDataHelper

require_relative '../shared/context_meta_data_helper_spec'
include ContextMetaDataHelper

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'batch edit' do
  describe 'batch remove from set' do

    it 'cancel button (no-js)', browser: :firefox_nojs do
      prepare_data
      login

      open_batch_ask_remove_from_set
      check_default_initial_content

      open_batch_ask_remove_from_set
      cancel_button.click
      check_return_to_page

      open_batch_ask_remove_from_set
      cancel_cross.click
      check_return_to_page
    end

    it 'remove button (no-js)', browser: :firefox_nojs do
      prepare_data
      login

      open_batch_ask_remove_from_set
      check_default_initial_content

      remove_button.click
      check_return_to_page

      expect(@parent_collection.reload.media_entries.length).to eq(0)
      expect(@parent_collection.reload.collections.length).to eq(0)
    end

    it 'cancel button (js)', browser: :firefox do
      prepare_data
      login

      visit parent_path

      select_all_box.click
      select_delete_from_set_button.click
      check_default_initial_content
      check_path(parent_path)
      cancel_button.click
      check_path(parent_path)
      check_no_dialog

      select_all_box.click
      select_delete_from_set_button.click
      check_default_initial_content
      check_path(parent_path)
      cancel_cross.click
      check_path(parent_path)
      check_no_dialog
    end
  end

  it 'remove button (js)', browser: :firefox do
    prepare_data
    login

    visit parent_path

    select_all_box.click
    select_delete_from_set_button.click
    check_default_initial_content
    check_path(parent_path)

    remove_button.click
    check_path(parent_path)

    expect(@parent_collection.reload.media_entries.length).to eq(0)
    expect(@parent_collection.reload.collections.length).to eq(0)
  end

  def prepare_data
    prepare_user
    @return_to_path = '/my'

    @media_entry1 = create_media_entry('MediaEntry1')
    @media_entry2 = create_media_entry('MediaEntry2')

    @collection1 = create_collection('Collection1')
    @collection2 = create_collection('Collection2')

    @parent_collection = create_collection('ParentCollection')

    @parent_collection.media_entries << [@media_entry1, @media_entry2]
    @parent_collection.collections << [@collection1, @collection2]
  end

  def check_path(path)
    expect(current_path).to eq(path)
  end

  def check_no_dialog
    expect(all('.modal').size).to eq(0)
  end

  def resource_ids_parameter
    [
      {
        uuid: @media_entry1.id,
        type: 'MediaEntry'
      },
      {
        uuid: @media_entry2.id,
        type: 'MediaEntry'
      },
      {
        uuid: @collection1.id,
        type: 'Collection'
      },
      {
        uuid: @collection2.id,
        type: 'Collection'
      }
    ]
  end

  def initial_url
    batch_ask_remove_from_set_path(
      resource_id: resource_ids_parameter,
      parent_collection_id: @parent_collection.id,
      return_to: @return_to_path)
  end

  def parent_path
    collection_path(@parent_collection)
  end

  def open_batch_ask_remove_from_set
    visit initial_url
  end

  def select_all_box
    find('.ui-filterbar').find('.icon-checkbox')
  end

  def select_delete_from_set_button
    menu_text = I18n.t('resources_box_batch_actions_menu_title', raise: false)
    action_text = I18n.t('resources_box_batch_actions_removefromset')
    within('.ui-filterbar') do
      dropdown_menu_and_get(menu_text, action_text)
    end
  end

  def check_initial_hint
    within('.ui-modal-body') do
      expect(page).to have_content(
        I18n.t(:batch_remove_from_collection_hint_pre) + 'ParentCollection' +
        I18n.t(:batch_remove_from_collection_hint_post))
      expect(page).to have_content(
        '2' + I18n.t(:batch_remove_from_collection_media_entries))
      expect(page).to have_content(
        '2' + I18n.t(:batch_remove_from_collection_collections))

    end
  end

  def check_default_initial_content
    check_initial_hint

    cancel_button
    cancel_cross
  end

  def remove_button
    within('.ui-modal-footer') do
      find('.primary-button', I18n.t(:batch_remove_from_collection_remove))
    end
  end

  def cancel_button
    within('.ui-modal-footer') do
      find('.link', I18n.t(:batch_remove_from_collection_cancel))
    end
  end

  def cancel_cross
    within('.ui-modal-head') do
      find('.icon-close')
    end
  end

  def check_return_to_page
    expect(current_path).to eq(@return_to_path)
  end
end
