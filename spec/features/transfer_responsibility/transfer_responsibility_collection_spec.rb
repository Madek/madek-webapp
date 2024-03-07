require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper

require_relative './transfer_responsibility_shared'
include TransferResponsibilityShared

feature 'Collection - transfer responsibility' do

  scenario 'check collection checkbox behaviour' do
    user = create(:user)
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
    user1 = create(:user)
    user2 = create(:user)
    collection = create_collection(user1)
    login_user(user1)
    open_permissions(collection)
    check_responsible_and_link(user1, true)
    click_transfer_link
    choose_user(user2)
    click_checkbox(:view)
    click_submit_button
    check_on_dashboard_after_loosing_view_rights
    open_permissions(collection)
    check_responsible_and_link(user2, false)
    check_no_permissions(user1, collection)
    check_notifications(user1, user2, collection)
  end

  scenario 'successful transfer responsibility for collection' do
    user1 = create(:user)
    user2 = create(:user)
    collection = create_collection(user1)
    login_user(user1)
    open_permissions(collection)
    check_responsible_and_link(user1, true)
    click_transfer_link
    choose_user(user2)
    click_checkbox(:manage)
    click_submit_button
    check_responsible_and_link(user2, false)
    check_permissions(user1, collection, true, nil, true, false)
  end

  scenario 'transfer responsibility to delegation and leave user with view & edit permissions' do
    user = create(:user)
    delegation = create(:delegation)
    collection = create_collection(user)
    login_user(user)
    open_permissions(collection)
    check_responsible_and_link(user, true)
    click_transfer_link
    choose_delegation(delegation)
    click_checkbox(:manage)
    click_submit_button
    check_responsible_and_link(delegation, false)
    open_permissions(collection)
    check_permissions(user, collection, true, nil, true, false)
  end

  scenario 'transfer responsibility to delegation and leave user with no permissions' do
    user = create(:user)
    delegation = create(:delegation)
    collection = create_collection(user)
    login_user(user)
    open_permissions(collection)
    check_responsible_and_link(user, true)
    click_transfer_link
    choose_delegation(delegation)
    click_checkbox(:view)
    click_submit_button
    check_on_dashboard_after_loosing_view_rights
    open_permissions(collection)
    check_no_permissions(user, collection)
  end

  context 'collection without public rights' do
    let(:user) { create(:user) }
    let(:collection) { create_collection(user, public_rights: false) }
    let(:delegation) { create(:delegation) }

    scenario 'transfer responsibility to delegation and leave user with no permissions' do
      login_user(user)
      open_permissions(collection)
      click_transfer_link
      choose_delegation(delegation)
      click_checkbox(:view)
      click_submit_button
      check_on_dashboard_after_loosing_view_rights
      open_permissions(collection)
      expect(page).to have_content(I18n.t(:error_403_title))
    end

    scenario 'transfer responsibility to delegation and leave user with view permission' do
      login_user(user)
      open_permissions(collection)
      click_transfer_link
      choose_delegation(delegation)
      click_checkbox(:edit)
      click_submit_button
      open_permissions(collection)
      check_permissions(user, collection, true, nil, false, false)
    end

    scenario 'transfer responsibility to delegation and leave user with view & edit permissions' do
      login_user(user)
      open_permissions(collection)
      click_transfer_link
      choose_delegation(delegation)
      click_checkbox(:manage)
      click_submit_button
      open_permissions(collection)
      check_permissions(user, collection, true, nil, true, false)
    end

    scenario 'transfer responsibility to delegation and leave user with all permissions' do
      login_user(user)
      open_permissions(collection)
      click_transfer_link
      choose_delegation(delegation)
      click_submit_button
      open_permissions(collection)
      check_permissions(user, collection, true, nil, true, true)
    end

    context 'when user belongs to the delegation' do
      before { delegation.users << user }

      scenario 'transfer responsibility to delegation and leave user with no permissions' do
        login_user(user)
        open_permissions(collection)
        click_transfer_link
        choose_delegation(delegation)
        click_checkbox(:view)
        click_submit_button
        check_on_dashboard_after_loosing_view_rights
        open_permissions(collection)
        check_responsible_and_link(delegation, true)
      end
    end
  end

  scenario 'batch transfer responsibility for collections' do
    user1 = create(:user)
    user2 = create(:user)
    collection1 = create_collection(user1, title: 'Collection 1')
    collection2 = create_collection(user2, title: 'Collection 2')
    collection3 = create_collection(user1, title: 'Collection 3')
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

    open_resource(parent)
    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(
      collections_transfer_responsibility: { count: 0, active: false }
    )
  end
end
