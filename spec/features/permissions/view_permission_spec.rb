require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'permissions', 'shared.rb')

feature 'View permission' do
  include Features::Permissions::Shared

  background do
    @current_user = sign_in_as 'Normin'
  end

  scenario 'Without permissions I cannot view a resource' do
    find_not_owned_resource_with_no_other_permissions
    visit media_resource_path(@resource)
    assert_exact_url_path '/my'
  end

  scenario "With view user-permission I can view the resource" do
    find_not_owned_resource_with_no_other_permissions

    add_user_permission_to_resource 'view'

    visit media_resource_path(@resource)
    expect(page).to have_css('.app-body-title h1', text: @resource.title)
  end

  scenario "With view user-permission I can't edit permissions" do
    find_not_owned_resource_with_no_other_permissions

    add_user_permission_to_resource 'view'

    visit media_resource_path(@resource)
    open_view_permissions_page
    expect(page).not_to have_css('button', text: 'Berechtigungen verwalten')
  end
end
