require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'permissions', 'shared.rb')

feature 'Edit permission' do
  include Features::Permissions::Shared

  background do
    @current_user = sign_in_as 'Normin'
  end

  scenario 'Without edit user-permission I cannot edit meta data' do
    find_not_owned_resource_with_no_other_permissions
    add_user_permission_to_resource 'view'

    visit edit_media_resource_path(@resource)
    assert_error_alert
  end

  scenario 'With edit user-permission I can edit meta data', browser: :firefox do
    find_not_owned_resource_with_no_other_permissions
    add_user_permission_to_resource 'view'
    add_user_permission_to_resource 'edit'

    visit media_resource_path(@resource)
    click_link 'Weitere Aktionen'
    click_link 'Metadaten editieren'
    assert_exact_url_path edit_media_resource_path(@resource)
    click_button 'Speichern'
    assert_exact_url_path media_entry_path(@resource)
    expect_confirmation_alert
  end
end
