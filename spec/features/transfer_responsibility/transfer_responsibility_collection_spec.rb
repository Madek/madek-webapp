require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper

require_relative './transfer_responsibility_shared'
include TransferResponsibilityShared

feature 'transfer responsibility media entry' do

  scenario 'check collection checkbox behaviour' do
    user = create_user
    collection = create_collection(user)
    login_user(user)
    open_permissions(collection)
    click_transfer_link
    check_checkboxes(Collection, true, nil, true, true)
    click_checkbox(:manage)
    check_checkboxes(Collection, true, nil, true, false)
    click_checkbox(:edit)
    check_checkboxes(Collection, true, nil, false, false)
    click_checkbox(:edit)
    check_checkboxes(Collection, true, nil, true, false)
    click_checkbox(:view)
    check_checkboxes(Collection, false, nil, false, false)
    click_checkbox(:view)
    check_checkboxes(Collection, true, nil, false, false)
  end

  scenario 'transfer responsibility for collection without new permissions' do
    user1 = create_user
    user2 = create_user
    collection = create_collection(user1)
    login_user(user1)
    open_permissions(collection)
    check_responsible_and_link(user1, true)
    click_transfer_link
    choose_user(user2)
    click_checkbox(:view)
    click_submit_button
    wait_until_form_disappeared
    check_responsible_and_link(user2, false)
    check_no_permissions(user1, collection)
  end

  scenario 'successful transfer responsibility for collection' do
    user1 = create_user
    user2 = create_user
    collection = create_collection(user1)
    login_user(user1)
    open_permissions(collection)
    check_responsible_and_link(user1, true)
    click_transfer_link
    choose_user(user2)
    click_checkbox(:manage)
    click_submit_button
    wait_until_form_disappeared
    check_responsible_and_link(user2, false)
    check_permissions(user1, collection, Collection, true, nil, true, false)
  end

  scenario 'batch transfer responsibility for collections' do
    user1 = create_user
    user2 = create_user
    collection1 = create_collection(user1, 'Collection 1')
    collection2 = create_collection(user2, 'Collection 2')
    collection3 = create_collection(user1, 'Collection 3')
    parent = create_collection(user1)

    all_collections = [collection1, collection2, collection3]
    add_all_to_parent(all_collections, parent)

    login_user(user1)
    open_resource(parent)
    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(
      collections_transfer_responsibility: {
        count: 2,
        highlights: [collection1, collection3] }
    )
    click_batch_action(:collections_transfer_responsibility)

    choose_user(user2)
    click_submit_button
    wait_until_form_disappeared

    open_resource(parent)
    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(
      collections_transfer_responsibility: { count: 0, active: false }
    )
  end
end
