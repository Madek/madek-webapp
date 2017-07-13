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

    click_dropdown
    check_full_dropdown(
      add_to_clipboard: { count: 6, all: true },
      add_to_set: { count: 0, active: false },
      remove_from_set: { count: 0, active: false },
      media_entries_metadata: { all: true },
      resources_destroy: { count: 0, active: false },
      collections_metadata: { all: true },
      media_entries_permissions: { count: 0, active: false },
      collections_permissions: { count: 0, active: false },
      media_entries_transfer_responsibility: { count: 0, active: false },
      collections_transfer_responsibility: { count: 0, active: false }
    )

    click_dropdown
    click_select_all_on_first_page

    click_dropdown
    check_full_dropdown(
      add_to_clipboard: { count: 6, all: false },
      add_to_set: { count: 6, highlights: all_resources },
      remove_from_set: { count: 6, highlights: all_resources },
      media_entries_metadata: { count: 3, highlights: media_entries_1_2_3 },
      collections_metadata: { count: 3, highlights: collections_1_2_3 },
      resources_destroy: { count: 6, highlights: all_resources },
      media_entries_permissions: { count: 3, highlights: media_entries_1_2_3 },
      collections_permissions: { count: 3 },
      media_entries_transfer_responsibility: { count: 3 },
      collections_transfer_responsibility: { count: 3 }
    )

    click_dropdown
    click_select_all_on_first_page
    select_media_entries(media_entries_1_3)

    click_dropdown
    check_full_dropdown(
      add_to_clipboard: { count: 2, all: false },
      add_to_set: { count: 2, highlights: media_entries_1_3 },
      remove_from_set: { count: 2, highlights: media_entries_1_3 },
      media_entries_metadata: { count: 2, highlights: media_entries_1_3 },
      collections_metadata: { count: 0, active: false, highlights: [] },
      resources_destroy: { count: 2, highlights: media_entries_1_3 },
      media_entries_permissions: { count: 2, highlights: media_entries_1_3 },
      collections_permissions: { count: 0, active: false, highlights: [] },
      media_entries_transfer_responsibility: {
        count: 2, highlights: media_entries_1_3 },
      collections_transfer_responsibility: {
        count: 0, active: false, highlights: [] }
    )

    click_dropdown
    click_select_all_on_first_page
    select_collections(collections_1_3)

    click_dropdown
    check_full_dropdown(
      add_to_clipboard: { count: 2, all: false },
      add_to_set: { count: 2, highlights: collections_1_3 },
      remove_from_set: { count: 2, highlights: collections_1_3 },
      media_entries_metadata: { count: 0, active: false, highlights: [] },
      collections_metadata: { count: 2, highlights: collections_1_3 },
      resources_destroy: { count: 2, highlights: collections_1_3 },
      media_entries_permissions: { count: 0, active: false, highlights: [] },
      collections_permissions: { count: 2, highlights: collections_1_3 },
      media_entries_transfer_responsibility: {
        count: 0, active: false, highlights: [] },
      collections_transfer_responsibility: {
        count: 2, highlights: collections_1_3 }
    )
  end
end
