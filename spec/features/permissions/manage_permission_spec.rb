require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'permissions', 'shared.rb')

feature 'Manage permission' do
  include Features::Permissions::Shared

  background do
    @current_user = sign_in_as 'Normin'
  end

  scenario "Without manage user-permission I can't edit permissions" do
    find_not_owned_resource_with_no_other_permissions
    add_user_permission_to_resource 'view'

    visit media_resource_path(@resource)
    open_view_permissions_page

    expect { check_permission_for 'normin', 'download' }.to raise_error
    expect(page).not_to have_css('button.primary-button[type=submit]')
  end

  scenario 'With manage user-permission I can edit permissions', browser: :firefox do
    find_not_owned_resource_with_no_other_permissions
    add_user_permission_to_resource 'view'
    add_user_permission_to_resource 'manage'

    visit media_resource_path(@resource)
    open_edit_permissions_page

    check_permission_for 'normin', 'edit'
    expect_submit_button
  end
end
