require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin Vocabulary Group Permissions' do
  let(:admin_user) { create :admin_user, password: 'password' }
  let(:vocabulary) { Vocabulary.find('orphans') }
  let(:group_permission) do
    create(:vocabulary_group_permission, use: false, view: true)
  end
  let(:new_group) { create :group }
  before { sign_in_as admin_user.login }

  scenario 'Creating a permission' do
    visit admin_vocabularies_path

    within find('table tbody tr', text: vocabulary.id) do
      click_link 'Group Permissions'
    end
    click_link 'Create Group Permission'
    expect(page).to_not have_button 'Save'
    click_link 'Choose group'

    expect(current_path).to eq(admin_groups_path)

    filter_with(new_group.name)

    within find('table tbody tr', text: new_group.name) do
      click_link 'Grant Vocabulary Permission'
    end

    expect(current_path).to eq(
      new_admin_vocabulary_vocabulary_group_permission_path(vocabulary.id))

    click_button 'Save'

    expect(page).to have_css(
      '.alert-success',
      text: 'The Vocabulary Group Permission has been created.')
  end

  scenario 'Editing a permission' do
    visit admin_vocabularies_path(search_term: group_permission.vocabulary.id)

    within find('table tbody tr', text: group_permission.vocabulary.id) do
      click_link 'Group Permissions'
    end
    within find('table tbody tr', text: group_permission.group.name) do
      click_link 'Edit'
    end
    expect(page).to have_button 'Save'
    click_link 'Choose group'

    expect(current_path).to eq(admin_groups_path)

    filter_with(new_group.name)

    within find('table tbody tr', text: new_group.name) do
      click_link 'Grant Vocabulary Permission'
    end

    expect(current_path).to eq(
      edit_admin_vocabulary_vocabulary_group_permission_path(
        group_permission.vocabulary_id, group_permission))

    check 'Can use?'
    uncheck 'Can view?'

    click_button 'Save'

    group_permission.reload
    expect(group_permission.group_id).to eq new_group.id
    expect(group_permission.use).to be true
    expect(group_permission.view).to be false

    expect(page).to have_css(
      '.alert-success',
      text: 'The Vocabulary Group Permission has been updated.')
  end

  def filter_with(group_name)
    fill_in 'search_terms', with: group_name
    click_button 'Apply'
  end
end
