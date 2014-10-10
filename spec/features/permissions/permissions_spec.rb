require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'permissions', 'shared.rb')

feature 'Permissions' do
  include Features::Permissions::Shared

  background do
    @current_user = sign_in_as 'Normin'
  end

  scenario 'Assigning and removing user permissions', browser: :firefox do
    remove_permissions_from_my_first_media_entry
    visit media_resource_path(@my_first_media_entry)
    open_edit_permissions_page
    fill_in 'user', with: 'Paula, Petra'
    select_entry_from_autocomplete_list 0, 'user'
    expect_checked_permission_for 'petra', 'view'
    check_permission_for 'petra', 'download'
    click_button 'Speichern'
    wait_for_ajax
    expect_user_to_have_permission 'petra', 'view'
    expect_user_to_have_permission 'petra', 'download'
    expect_user_to_have_permission 'petra', 'edit', false

    visit media_resource_path(@my_first_media_entry)
    open_edit_permissions_page
    remove_from_permissions 'Paula, Petra'
    click_button 'Speichern'
    wait_for_ajax
    expect_no_permissions_for_user 'petra'
  end

  scenario 'Assigning and removing group permissions', browser: :firefox do
    remove_permissions_from_my_first_media_entry

    visit media_resource_path(@my_first_media_entry)
    open_edit_permissions_page

    within '#addGroup' do
      fill_in 'group', with: 'Zett'
    end
    select_entry_from_autocomplete_list 0, 'group'
    expect_checked_permission_for 'Zett', 'view'
    check_permission_for 'Zett', 'download'
    click_button 'Speichern'
    wait_for_ajax
    expect_group_to_have_permission 'Zett', 'view'
    expect_group_to_have_permission 'Zett', 'download'
    expect_group_to_have_permission 'Zett', 'edit', false

    visit media_resource_path(@my_first_media_entry)
    open_edit_permissions_page
    remove_from_permissions 'Zett'
    click_button 'Speichern'
    wait_for_ajax
    expect_no_permissions_for_group 'Zett'
  end

  scenario 'Display the complete LDAP name on the selection dropdown', browser: :firefox do
    setup_departments_with_ldap_references
    remove_permissions_from_my_first_media_entry(true)

    visit media_resource_path(@my_first_media_entry)
    open_edit_permissions_page

    within '#addGroup' do
      fill_in 'group', with: 'Vertiefung Industrial Design'
    end
    select_entry_from_autocomplete_list 'Vertiefung Industrial Design (DDE_FDE_VID.dozierende)', 'group'
    click_button 'Speichern'
    wait_for_ajax
    expect_view_page_of_resource_permissions
    expect_confirmation_alert
  end

  scenario 'Permissions for adding a resource to a set', browser: :firefox do
    create_not_owned_resource_with_file_with_no_permissions
    add_user_permission_to_resource 'view'
    add_user_permission_to_resource 'edit'
    find_not_owned_set_with_to_permissions_and_no_children
    add_user_permission_to_set 'view'
    add_user_permission_to_set 'edit'

    visit media_resource_path(@resource)

    click_link 'Weitere Aktionen'
    find('a', text: 'Zu Set hinzufügen/entfernen').click
    add_resource_to_group
    expect_set_to_include_resource
  end

  scenario 'Permission presets', browser: :firefox do
    find_owned_resource_with_permissions_for 'petra'

    visit media_resource_path(@resource)
    open_edit_permissions_page
    wait_for_ajax
    expect_select_for_permission_presets
  end

  scenario "Limiting what other users' permissions I can see", browser: :firefox do
    find_owned_resource_with_no_other_permissions

    add_user_permission_to_resource 'view'
    add_user_permission_to_resource 'download'
    add_user_permission_to_resource 'edit'
    add_user_permission_to_resource 'manage'

    add_user_permission_to_resource 'view', 'petra'

    add_user_permission_to_resource 'view', 'beat'
    add_user_permission_to_resource 'edit', 'beat'
    add_user_permission_to_resource 'download', 'beat'

    add_user_permission_to_resource 'view', 'liselotte'
    add_user_permission_to_resource 'edit', 'liselotte'
    add_user_permission_to_resource 'download', 'liselotte'

    logout
    sign_in_as 'Normin'

    visit media_resource_path(@resource)
    open_edit_permissions_page

    expect_checked_permission_for 'normin', 'view'
    expect_checked_permission_for 'normin', 'download'
    expect_checked_permission_for 'normin', 'edit'
    expect_checked_permission_for 'normin', 'manage'

    expect_checked_permission_for 'petra', 'view'

    expect_checked_permission_for 'beat', 'edit'
    expect_checked_permission_for 'beat', 'download'

    expect_checked_permission_for 'liselotte', 'edit'
    expect_checked_permission_for 'liselotte', 'download'

    logout
    sign_in_as 'Beat'

    visit media_resource_path(@resource)
    open_view_permissions_page

    expect_checked_permission_for 'normin', 'view'
    expect_checked_permission_for 'petra', 'view'

    logout
    sign_in_as 'Liselotte'

    visit media_resource_path(@resource)
    open_view_permissions_page

    expect_checked_permission_for 'normin', 'edit'
    expect_checked_permission_for 'beat', 'edit'
    expect_checked_permission_for 'liselotte', 'edit'

    logout
    sign_in_as 'Petra'

    visit media_resource_path(@resource)
    open_view_permissions_page

    expect_checked_permission_for 'normin', 'view'
    expect_checked_permission_for 'petra', 'view'

    logout
  end
end
