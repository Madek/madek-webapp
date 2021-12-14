require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/favorite_helper_spec'
require_relative '../shared/basic_data_helper_spec'
include FavoriteHelper
include BasicDataHelper

feature 'Collection tabs' do

  scenario 'Check tabs with content' do
    setup_contexts_for_collection_extra
    prepare_user
    @collection = create_collection('Title')
    @parent = create_collection('Parent')
    @collection.parent_collections << @parent
    login

    visit collection_path(@collection)
    check_tabs('show', 'show')
    visit relations_collection_path(@collection)
    check_tabs('relations', 'relations')
    visit relation_children_collection_path(@collection)
    check_tabs('relations', 'relations_children')
    visit relation_siblings_collection_path(@collection)
    check_tabs('relations', 'relations_siblings')
    visit relation_parents_collection_path(@collection)
    check_tabs('relations', 'relations_parents')
    visit usage_data_collection_path(@collection)
    check_tabs('usage_data', 'usage_data')
    visit more_data_collection_path(@collection)
    check_tabs('more_data', 'more_data')
    visit permissions_collection_path(@collection)
    check_tabs('permissions', 'permissions')
    visit edit_permissions_collection_path(@collection)
    check_tabs('permissions', 'permissions')
    visit context_collection_path(@collection, 'core')
    check_tabs('show', 'context_core')
    visit context_collection_path(@collection, 'media_content')
    check_tabs('context_media_content', 'context_media_content')
  end

  def check_tabs(tab_id, tab_content_id)
    full_tab_id = 'set_tab_' + tab_id
    full_tab_content_id = 'set_tab_content_' + tab_content_id

    # NOTE: Check id of active tab.
    find('[class="active ui-tabs-item"][data-test-id="' + full_tab_id + '"]')
    # NOTE: Check id of content.
    find('[data-test-id="' + full_tab_content_id + '"]')

    # NOTE: Make sure you have 6 of 7 inactive tabs.
    selector = '.ui-tabs-item[data-test-id*=set_tab]:not([class*=active])'
    inactive_tabs = all(selector)
    expect(inactive_tabs.length).to eq(6)
  end

  def setup_contexts_for_collection_extra
    app_settings = AppSetting.first
    app_settings[:contexts_for_collection_extra] << 'core'
    app_settings[:contexts_for_collection_extra] << 'media_content'
    app_settings.save
  end
end
