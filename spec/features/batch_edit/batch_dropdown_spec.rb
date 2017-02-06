require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/favorite_helper_spec'
require_relative '../shared/basic_data_helper_spec'
include FavoriteHelper
include BasicDataHelper

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper
require_relative '../shared/batch_data_helper'
include BatchDataHelper

feature 'Batch dropdown' do

  scenario 'Check dropdown menu and highlighting according to selection' do
    prepare_user
    prepare_data
    login
    visit collection_path(@parent_collection)

    open_dropdown
    check_all_items_inactive
    check_given_counts(
      add_to_set: 0,
      remove_from_set: 0,
      media_entries_metadata: 0,
      collections_metadata: 0,
      media_entries_permissions: 0
    )

    toggle_select_all

    open_dropdown
    check_all_items_active
    check_given_counts(
      add_to_set: 6,
      remove_from_set: 6,
      media_entries_metadata: 3,
      collections_metadata: 3,
      media_entries_permissions: 3
    )
    check_given_highlights(
      add_to_set: all_resources,
      remove_from_set: all_resources,
      media_entries_metadata: media_entries_1_2_3,
      collections_metadata: collections_1_2_3,
      media_entries_permissions: media_entries_1_2_3
    )

    toggle_select_all
    select_media_entries(media_entries_1_3)

    open_dropdown
    check_given_items_active(
      add_to_set: true,
      remove_from_set: true,
      media_entries_metadata: true,
      media_entries_permissions: true
    )
    check_given_counts(
      add_to_set: 2,
      remove_from_set: 2,
      media_entries_metadata: 2,
      collections_metadata: 0,
      media_entries_permissions: 2
    )
    check_given_highlights(
      add_to_set: media_entries_1_3,
      remove_from_set: media_entries_1_3,
      media_entries_metadata: media_entries_1_3,
      collections_metadata: [],
      media_entries_permissions: media_entries_1_3
    )

    toggle_select_all
    select_collections(collections_1_3)

    open_dropdown
    check_given_items_active(
      add_to_set: true,
      remove_from_set: true,
      collections_metadata: true
    )
    check_given_counts(
      add_to_set: 2,
      remove_from_set: 2,
      media_entries_metadata: 0,
      collections_metadata: 2,
      media_entries_permissions: 0
    )
    check_given_highlights(
      add_to_set: collections_1_3,
      remove_from_set: collections_1_3,
      media_entries_metadata: [],
      collections_metadata: collections_1_3,
      media_entries_permissions: []
    )
  end
end
