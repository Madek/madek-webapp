require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin Vocabulary API Client Permissions' do
  let(:admin_user) { create :admin_user, password: 'password' }
  let(:vocabulary) { Vocabulary.find('orphans') }
  let!(:api_client_permission) do
    create(:vocabulary_api_client_permission, use: false, view: true)
  end
  let!(:new_api_client) { create :api_client }
  before do
    3.times { create :api_client }
    sign_in_as admin_user.login
  end

  scenario 'Creating a permission' do
    visit admin_vocabularies_path

    within find('table tbody tr', text: vocabulary.id) do
      click_link 'API Client Permissions'
    end
    click_link 'Create API Client Permission'
    expect(page).to_not have_button 'Save'
    click_link 'Choose API Client'

    expect(current_path).to eq(admin_api_clients_path)

    within find('table tbody tr', text: new_api_client.login) do
      click_link 'Grant Vocabulary Permission'
    end

    expect(current_path).to eq(
      new_admin_vocabulary_vocabulary_api_client_permission_path(vocabulary.id))

    click_button 'Save'

    expect(page).to have_css(
      '.alert-success',
      text: 'The Vocabulary Api Client Permission has been created.')
  end

  scenario 'Editing a permission' do
    visit admin_vocabularies_path(search_term: api_client_permission.vocabulary.id)

    within find('table tbody tr',
                text: api_client_permission.vocabulary.id,
                match: :first) do
      click_link 'API Client Permissions'
    end
    within find('table tbody tr', text: api_client_permission.api_client.login) do
      click_link 'Edit'
    end
    expect(page).to have_button 'Save'
    click_link 'Choose API Client'

    expect(current_path).to eq(admin_api_clients_path)

    within find('table tbody tr', text: new_api_client.login) do
      click_link 'Grant Vocabulary Permission'
    end

    expect(current_path).to eq(
      edit_admin_vocabulary_vocabulary_api_client_permission_path(
        api_client_permission.vocabulary_id, api_client_permission))

    check 'Can use?'
    uncheck 'Can view?'

    click_button 'Save'

    api_client_permission.reload
    expect(api_client_permission.api_client_id).to eq new_api_client.id
    expect(api_client_permission.use).to be true
    expect(api_client_permission.view).to be false

    expect(page).to have_css(
      '.alert-success',
      text: 'The Vocabulary Api Client Permission has been updated.')
  end
end
