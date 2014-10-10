require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Admin Usage Terms' do
  background { sign_in_as 'Adam' }

  scenario 'Updating Usage Terms', browser: :firefox do
    visit '/app_admin'
    click_link_from_menu 'Usage terms', 'Settings'
    assert_exact_url_path '/app_admin/usage_terms'
    click_link 'Edit'
    fill_in 'usage_term[title]', with: 'New title'
    submit_form
    assert_success_message
    find_button 'Akzeptieren'
  end

  scenario 'Resetting usage terms acceptance of a user', browser: :firefox do
    visit '/app_admin/users'
    click_link 'Reset usage terms', match: :first
    find_button 'Akzeptieren'
  end
end
