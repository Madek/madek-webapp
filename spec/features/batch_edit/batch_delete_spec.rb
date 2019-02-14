require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper
require_relative './shared/batch_shared_dropdown_spec'

feature 'batch delete' do

  scenario 'delete' do
    user1 = create_user
    user2 = create_user

    media_entry_1 = create_media_entry('Media Entry 1', user1)
    media_entry_2 = create_media_entry('Media Entry 2', user1)
    media_entry_3 = create_media_entry('Media Entry 3', user2)
    give_all_permissions(media_entry_3, user1)

    collection_1 = create_collection('Collection 1', user1)
    collection_2 = create_collection('Collection 2', user2)
    give_all_permissions(collection_2, user1)

    all_media_entries =
      [media_entry_1, media_entry_2, media_entry_3]
    all_collections = [collection_1, collection_2]
    all_resources = all_media_entries.concat(all_collections)

    parent = create_collection('Parent', user1)
    add_all_to_parent(all_resources, parent)

    media_entries_before = MediaEntry.all.count
    collections_before = Collection.all.count

    login(user1)
    visit_resource(parent)
    check_resources_in_box(
      all_resources
    )

    click_select_all_on_first_page
    click_dropdown
    check_full_dropdown(
      add_to_clipboard: { count: 5, all: false },
      add_to_set: { count: 5 },
      remove_from_set: { count: 5 },
      media_entries_metadata: { count: 3 },
      resources_destroy: { count: 3 },
      collections_metadata: { count: 2 },
      media_entries_permissions: { count: 3 },
      collections_permissions: { count: 2 },
      media_entries_transfer_responsibility: { count: 2 },
      collections_transfer_responsibility: { count: 1 },
      meta_data_batch: false
    )
    click_batch_action(:resources_destroy)

    check_delete_question(2, 1)
    click_delete_question_ok
    check_delete_success_message

    expect(parent.collections.count).to eq(1)
    expect(parent.media_entries.count).to eq(1)

    media_entries_after = MediaEntry.all.count
    collections_after = Collection.all.count

    expect(media_entries_before - media_entries_after).to eq(3 - 1)
    expect(collections_before - collections_after).to eq(2 - 1)
  end
end
