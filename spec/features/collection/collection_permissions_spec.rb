require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../media_entry/permissions/_shared'
include MediaEntryPermissionsShared

def permission_types
  %i(
    get_metadata_and_previews
    edit_metadata_and_relations
    edit_permissions
  )
end

feature 'Resource: Collection' do
  given(:user) { create(:user) }
  given(:entrusted_user) { create(:user, password: 'password') }
  given(:collection) { create(:collection, responsible_user: user) }
  given(:delegation) { create(:delegation) }
  given!(:searchable_delegation) { create(:delegation, name: 'Awesome Group') }
  given(:direct_delegation_member) do
    user = create(:user, password: 'password')
    delegation.users << user
    user
  end
  given(:delegation_member_through_group) do
    user = create(:user)
    group = create(:group)
    group.users << user
    delegation.groups << group
    user
  end

  scenario 'edit permissions (some perms for user, group, client)' do
    sign_in_as user

    visit permissions_collection_path(collection)
    click_link I18n.t(:permissions_table_edit_btn)

    test_perm = grant_view_permission
    other_perm = permission_types[1]

    expect(current_path).to eq permissions_collection_path(collection)

    expect(collection.user_permissions.length).to eq 2
    expect(collection.user_permissions.first[test_perm]).to be true
    expect(collection.user_permissions.first[other_perm]).to be false
    new_delegation_permission = collection
                                  .user_permissions
                                  .find_by(delegation: searchable_delegation)
    expect(new_delegation_permission[test_perm]).to be true
    expect(new_delegation_permission[other_perm]).to be false

    expect(collection.group_permissions.length).to eq 1
    expect(collection.group_permissions.first[test_perm]).to be true
    expect(collection.group_permissions.first[other_perm]).to be false

    expect(collection.api_client_permissions.length).to eq 1
    expect(collection.api_client_permissions.first[test_perm]).to be true
    expect(collection.api_client_permissions.first[other_perm]).to be false
  end

  scenario 'edit permissions as entrusted user (full perms for user, group, client)' do
    create(
      :collection_user_permission,
      collection: collection, user: entrusted_user,
      get_metadata_and_previews: true, edit_metadata_and_relations: true,
      edit_permissions: true)

    sign_in_as entrusted_user

    visit permissions_collection_path(collection)
    click_link I18n.t(:permissions_table_edit_btn)

    user_perms = permission_types
    group_perms = permission_types.first(2)
    api_perm = permission_types.first

    save_permissions do
      user_perms.each(&method(:grant_user_permission))
      group_perms.each(&method(:grant_group_permission))
      grant_api_permission(api_perm)
    end

    expect(current_path).to eq permissions_collection_path(collection)

    new_user_permission = collection.user_permissions.where.not(user: entrusted_user).first
    expect(new_user_permission).to be

    expect(collection.user_permissions.length).to eq 3
    expect(collection.group_permissions.length).to eq 1
    expect(collection.api_client_permissions.length).to eq 1

    user_perms.each do |perm_type|
      expect(new_user_permission[perm_type]).to be true
    end
    group_perms.each do |perm_type|
      expect(collection.group_permissions.first[perm_type]).to be true
    end
    expect(collection.api_client_permissions.first[api_perm]).to be true
  end

  scenario 'edit permissions as a direct member of delegation '\
           '(some perms for user, group, client)' do
    create(
      :collection_user_permission,
      collection: collection, delegation: delegation, user: nil,
      get_metadata_and_previews: true, edit_metadata_and_relations: true,
      edit_permissions: true)

    sign_in_as direct_delegation_member

    visit permissions_collection_path(collection)
    click_link I18n.t(:permissions_table_edit_btn)

    grant_view_permission

    expect(current_path).to eq permissions_collection_path(collection)
    expect_view_permissions
  end

  scenario 'edit permissions as a member of delegation through a group '\
           '(some perms for user, group, client)' do
    create(
      :collection_user_permission,
      collection: collection, delegation: delegation, user: nil,
      get_metadata_and_previews: true, edit_metadata_and_relations: true,
      edit_permissions: true)

    sign_in_as delegation_member_through_group

    visit permissions_collection_path(collection)
    click_link I18n.t(:permissions_table_edit_btn)

    grant_view_permission

    expect(current_path).to eq permissions_collection_path(collection)
    expect_view_permissions
  end
end

def save_permissions
  yield
  click_button I18n.t(:permissions_table_save_btn)
  collection.reload
end

def grant_view_permission
  permission = permission_types.first

  save_permissions do
    grant_user_permission(permission)
    grant_group_permission(permission)
    grant_api_permission(permission)
  end

  permission
end

def find_form
  @_form ||= find('form[name="ui-rights-management"]')
end

def grant_user_permission(perm_type)
  translation_key = :permission_subject_title_users_or_delegations
  add_subject_with_permission(subject_row(find_form, I18n.t(translation_key)),
                              'Norbert',
                              perm_type)
  add_subject_with_permission(subject_row(find_form, I18n.t(translation_key)),
                              'Awesome',
                              perm_type)
end

def grant_group_permission(perm_type)
  add_subject_with_permission(subject_row(find_form, I18n.t(:permission_subject_title_groups)),
                              'Diplomarbeitsg',
                              perm_type)
end

def grant_api_permission(perm_type)
  add_subject_with_permission(subject_row(find_form, I18n.t(:permission_subject_title_apiapps)),
                              'fancy',
                              perm_type)
end

def expect_view_permissions
  view_permission = permission_types.first
  other_perm = permission_types.second

  expect(collection.user_permissions.length).to eq 3
  new_user_permission = collection.user_permissions.where(delegation_id: nil).first
  expect(new_user_permission[view_permission]).to be true
  expect(new_user_permission[other_perm]).to be false
  new_delegation_permission = collection
                                .user_permissions
                                .find_by(delegation: searchable_delegation)
  expect(new_delegation_permission[view_permission]).to be true
  expect(new_delegation_permission[other_perm]).to be false

  expect(collection.group_permissions.length).to eq 1
  expect(collection.group_permissions.first[view_permission]).to be true
  expect(collection.group_permissions.first[other_perm]).to be false

  expect(collection.api_client_permissions.length).to eq 1
  expect(collection.api_client_permissions.first[view_permission]).to be true
  expect(collection.api_client_permissions.first[other_perm]).to be false
end
