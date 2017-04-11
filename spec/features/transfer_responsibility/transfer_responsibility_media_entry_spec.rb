require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper

require_relative './transfer_responsibility_shared'
include TransferResponsibilityShared

feature 'transfer responsibility collection' do

  scenario 'check media entry checkbox behaviour' do
    user = create_user
    media_entry = create_media_entry(user)
    login_user(user)
    open_permissions(media_entry)
    click_transfer_link
    check_checkboxes(MediaEntry, true, true, true, true)
    click_checkbox(:download)
    check_checkboxes(MediaEntry, true, false, false, false)
    click_checkbox(:manage)
    check_checkboxes(MediaEntry, true, true, true, true)
    click_checkbox(:edit)
    check_checkboxes(MediaEntry, true, true, false, false)
    click_checkbox(:edit)
    check_checkboxes(MediaEntry, true, true, true, false)
    click_checkbox(:view)
    check_checkboxes(MediaEntry, false, false, false, false)
    click_checkbox(:view)
    check_checkboxes(MediaEntry, true, false, false, false)
  end

  scenario 'transfer responsibility for media entry without new permissions' do
    user1 = create_user
    user2 = create_user
    media_entry = create_media_entry(user1)
    login_user(user1)
    open_permissions(media_entry)
    check_responsible_and_link(user1, true)
    click_transfer_link
    choose_user(user2)
    click_checkbox(:view)
    click_submit_button
    wait_until_form_disappeared
    check_responsible_and_link(user2, false)
    check_no_permissions(user1, media_entry)
  end

  scenario 'successful transfer responsibility for media entry' do
    user1 = create_user
    user2 = create_user
    media_entry = create_media_entry(user1)
    login_user(user1)
    open_permissions(media_entry)
    check_responsible_and_link(user1, true)
    click_transfer_link
    choose_user(user2)
    click_checkbox(:edit)
    click_submit_button
    wait_until_form_disappeared
    check_responsible_and_link(user2, false)
    check_permissions(user1, media_entry, MediaEntry, true, true, false, false)
  end

  scenario 'batch transfer responsibility for media entries' do
    user1 = create_user
    user2 = create_user
    media_entry1 = create_media_entry(user1, 'Media Entry 1')
    media_entry2 = create_media_entry(user2, 'Media Entry 2')
    media_entry3 = create_media_entry(user1, 'Media Entry 3')
    parent = create_collection(user1)

    all_media_entries = [media_entry1, media_entry2, media_entry3]
    add_all_to_parent(all_media_entries, parent)

    login_user(user1)
    open_resource(parent)
    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(
      media_entries_transfer_responsibility: {
        count: 2,
        highlights: [media_entry1, media_entry3] }
    )
    click_batch_action(:media_entries_transfer_responsibility)

    choose_user(user2)
    click_submit_button
    wait_until_form_disappeared

    open_resource(parent)
    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(
      media_entries_transfer_responsibility: { count: 0, active: false }
    )
  end
end
