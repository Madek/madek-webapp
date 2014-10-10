require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'permissions', 'shared.rb')

feature 'Download permission' do
  include Features::Permissions::Shared

  background do
    @current_user = sign_in_as 'Normin'
  end

  scenario "Without download user-permission I can't download the resource", browser: :firefox do
    create_not_owned_resource_with_file_with_no_permissions
    add_user_permission_to_resource 'view'

    visit media_resource_path(@resource)

    click_on_text 'Weitere Aktionen'
    find('#ui-export-button').click
    assert_modal_visible 'Ohne Titel exportieren'

    within '#ui-export-dialog' do
      click_on_text 'Datei ohne Metadaten'
    end
    within 'ul.download' do
      expect(page).not_to have_css('a.original')
    end
  end

  scenario "With download user-permission I can download the resource", browser: :firefox do
    create_not_owned_resource_with_file_with_no_permissions
    add_user_permission_to_resource 'view'
    add_user_permission_to_resource 'download'

    visit media_resource_path(@resource)

    click_on_text 'Weitere Aktionen'
    find('#ui-export-button').click
    assert_modal_visible 'Ohne Titel exportieren'

    within '#ui-export-dialog' do
      click_on_text 'Datei ohne Metadaten'
    end
    within 'ul.download' do
      expect(page).to have_css('a.original')
    end
  end
end
