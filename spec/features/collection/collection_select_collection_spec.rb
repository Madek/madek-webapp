require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/select_collection_helper_spec'
include SelectCollectionHelper

feature 'MediaEntry: Select Collection' do

  describe 'Action: show' do
    scenario 'Modal dialog is shown', browser: :firefox_nojs do
      scenario_modal_dialog_is_shown
    end

    scenario 'Modal dialog cancel', browser: :firefox_nojs do
      scenario_modal_dialog_cancel
    end

    desc = 'Initial sets are equal to parent collections'
    scenario desc, browser: :firefox_nojs do
      scenario_initial_sets_are_equal_to_parent_collections
    end

    scenario 'Search for collections', browser: :firefox_nojs do
      scenario_search_for_collections
    end

    scenario 'Save no checkboxes visible', browser: :firefox_nojs do
      scenario_save_no_checkboxes_visible
    end
  end

  describe 'Action: create' do

    scenario 'Add and remove a collection', browser: :firefox_nojs do
      scenario_add_and_remove_a_collection
    end
  end

  pending 'Do the same tests like above async.' do
    # => When done async, the set list in the set selection gets longer
    # => and the save button disappears, which does not work on CI
    fail 'not implemented'
  end

  private # expected methods from select_collection_helper_spec.rb

  def expected_flash_message(removed, added)
    I18n.t(
      :collection_select_collection_flash_result,
      removed_count: removed, added_count: added)
  end

  def prepare_resource
    @resource = Collection.create!(
      get_metadata_and_previews: true,
      responsible_user: @user,
      creator: @user)
    MetaDatum::Text.create!(
      collection: @resource,
      string: 'Mein Set',
      meta_key: meta_key_title,
      created_by: @user)
  end

  def resource_path
    collection_path(@resource)
  end

  def child_resources(collection)
    collection.collections
  end

  def select_collection_path
     select_collection_collection_path(@resource)
  end
end
