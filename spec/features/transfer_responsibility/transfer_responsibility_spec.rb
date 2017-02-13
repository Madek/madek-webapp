require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper

require_relative './transfer_responsibility_shared'
include TransferResponsibilityShared

feature 'transfer responsibility shared' do

  scenario 'check link visible if responsible' do
    user = create_user
    media_entry = create_media_entry(user)
    login_user(user)
    open_permissions(media_entry)
    check_responsible_and_link(user, true)
  end

  scenario  'check link not visible if not responsible' do
    user1 = create_user
    user2 = create_user
    media_entry = create_media_entry(user1)
    login_user(user2)
    open_permissions(media_entry)
    check_responsible_and_link(user1, false)
  end

  scenario 'check clear user' do
    user1 = create_user
    user2 = create_user
    media_entry = create_media_entry(user1)
    login_user(user1)
    open_permissions(media_entry)
    click_transfer_link
    check_submit(false)
    choose_user(user2)
    check_submit(true)
    click_clear_user
    check_submit(false)
  end

  scenario 'check selecting responsible user' do
    user = create_user
    media_entry = create_media_entry(user)
    login_user(user)
    open_permissions(media_entry)
    click_transfer_link
    check_submit(false)
    choose_user(user)
    check_submit(false)
  end

  scenario 'transfer responsibility for not responsible media entry' do
    user1 = create_user
    user2 = create_user
    media_entry = create_media_entry(user1)
    login_user(user1)
    open_permissions(media_entry)
    check_responsible_and_link(user1, true)
    click_transfer_link

    media_entry.responsible_user = user2
    media_entry.save!
    media_entry.reload
    choose_user(user2)
    click_submit_button

    check_error_message(:ajax_form_no_longer_authorized)
    click_cancel_button
    check_responsible_and_link(user1, true)
  end

  scenario 'check batch selection' do
    user1 = create_user
    user2 = create_user
    media_entry1 = create_media_entry(user1, 'Media Entry 1')
    media_entry2 = create_media_entry(user2, 'Media Entry 2')
    media_entry3 = create_media_entry(user1, 'Media Entry 3')
    media_entry4 = create_media_entry(user2, 'Media Entry 4')
    collection1 = create_collection(user1, 'Collection 1')
    collection2 = create_collection(user2, 'Collection 2')
    collection3 = create_collection(user2, 'Collection 3')
    parent = create_collection(user1)

    all_media_entries = [media_entry1, media_entry2, media_entry3, media_entry4]
    all_collections = [collection1, collection2, collection3]
    all_resources = all_media_entries.concat all_collections

    unpublish(media_entry3)
    give_all_permissions(media_entry4, user1)
    add_all_to_parent(all_resources, parent)

    login_user(user1)
    open_resource(parent)

    open_dropdown
    check_all_items_inactive
    toggle_select_all

    open_dropdown
    check_all_counts(
      add_to_set: 6,
      remove_from_set: 6,
      media_entries_metadata: 2,
      collections_metadata: 1,
      media_entries_permissions: 2,
      collections_permissions: 1,
      media_entries_transfer_responsibility: 1,
      collections_transfer_responsibility: 1
    )
    check_all_highlights(
      add_to_set: all_media_entries,
      remove_from_set: all_media_entries,
      media_entries_metadata: [media_entry1, media_entry4],
      collections_metadata: [collection1],
      media_entries_permissions: [media_entry1, media_entry4],
      collections_permissions: [collection1],
      media_entries_transfer_responsibility: [media_entry1],
      collections_transfer_responsibility: [collection1]
    )
  end
end
