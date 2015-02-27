require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin Api Clients' do
  background do
    @admin_user = create :admin_user, password: 'password'
    sign_in_as @admin_user.login
  end

  scenario 'Creating a new API Client' do
    visit admin_api_clients_path
    click_link 'Create API Client'
    expect(current_path).to eq new_admin_api_client_path

    fill_in 'api_client[login]', with: 'test-login'
    click_button 'Save'

    expect(page).to have_content 'test-login'
    expect(ApiClient.find_by(login: 'test-login')).to be
  end

  scenario 'Deleting an API Client', browser: :firefox do
    api_client = create :api_client

    visit admin_api_client_path(api_client)
    accept_confirm do
      click_link 'Delete'
    end

    expect(current_path).to eq admin_api_clients_path
    expect { api_client.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario 'Editing an API Client' do
    api_client = create :api_client
    user_select_value = "#{api_client.user.person} [#{api_client.user.login}]"

    visit admin_api_client_path(api_client)
    click_link 'Edit'
    expect(page).to have_select('User', selected: user_select_value)
    fill_in 'api_client[description]', with: 'test description'
    click_button 'Save'

    api_client.reload
    expect(current_path).to eq admin_api_client_path(api_client)
    expect(api_client.description).to eq 'test description'
  end
end
