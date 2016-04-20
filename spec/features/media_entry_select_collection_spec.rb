require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative 'shared/select_collection_helper_spec'
include SelectCollectionHelper

feature 'MediaEntry: Select Collection' do

  describe 'Action: show' do
    scenario 'Modal dialog is shown', browser: :firefox do
      scenario_modal_dialog_is_shown
    end

    scenario 'Modal dialog cancel', browser: :firefox do
      scenario_modal_dialog_cancel
    end

    scenario 'Initial sets are equal to parent collections', browser: :firefox do
      scenario_initial_sets_are_equal_to_parent_collections
    end

    scenario 'Search for collections', browser: :firefox do
      scenario_search_for_collections
    end

    scenario 'Save no checkboxes visible', browser: :firefox do
      scenario_save_no_checkboxes_visible
    end
  end

  describe 'Action: create' do

    scenario 'Add and remove a collection', browser: :firefox do
      scenario_add_and_remove_a_collection
    end
  end

  private # expected methods from select_collection_helper_spec.rb

  def expected_flash_message(removed, added)
    ('Removed entry from ' + removed.to_s + ' sets.')
      .concat(' Added entry to ' + added.to_s + ' sets.')
  end

  def prepare_resource
    @resource = FactoryGirl.create(
      :media_entry,
      responsible_user: @user,
      creator: @user)

    @media_file = FactoryGirl.create(
      :media_file_for_image,
      media_entry: @resource)

    FactoryGirl.create(
      :meta_datum_text,
      created_by: @user,
      meta_key: meta_key_title,
      media_entry: @resource,
      value: 'Medien Eintrag 1')
  end

  def resource_path
    media_entry_path(@resource)
  end

  def child_resources(collection)
    collection.media_entries
  end

  def select_collection_path
     select_collection_media_entry_path(@resource)
  end

end
