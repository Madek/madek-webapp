require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'My Groups' do
  let(:user) { User.find_by(login: 'normin') }
  let(:group) { create(:group) }
  background do
    sign_in_as user.login
    group.users << user
  end

  scenario 'Creating a group' do
    visit my_groups_path

    click_on 'Neue Arbeitsgruppe'

    expect(current_path).to eq new_my_group_path

    fill_in 'Name', with: 'NEW_GROUP'
    submit_form

    within '.ui-workgroups' do
      expect(page).to have_content 'NEW_GROUP'
    end
  end

  scenario 'Creating a group with duplicated name' do
    create :group, name: 'NEW_GROUP'

    visit my_groups_path

    click_on 'Neue Arbeitsgruppe'

    expect(current_path).to eq new_my_group_path

    fill_in 'Name', with: 'NEW_GROUP'
    submit_form

    expect(page).to have_content('Validation failed: Name has already been taken')
  end

  scenario 'Editing a group' do
    visit my_groups_path

    within "[data-id='#{group.id}']" do
      click_link 'Edit'
    end

    fill_in 'Name', with: 'NEW NAME'
    submit_form

    within '.ui-workgroups' do
      expect(page).not_to have_content group.name
      expect(page).to have_content 'NEW NAME'
    end
  end

  scenario 'Deleting a group' do
    visit my_groups_path

    within "[data-id='#{group.id}'] .ui-workgroup-actions" do
      find('button[data-confirm]').click
    end

    expect(current_path).to eq my_groups_path

    within '.ui-workgroups' do
      expect(page).not_to have_content group.name
    end
  end

  scenario 'Showing a group' do
    visit my_groups_path

    within "[data-id='#{group.id}']" do
      click_link group.name
    end

    expect(current_path).to eq my_group_path(group)

    within '.ui-body-title' do
      expect(page).to have_content group.name
    end
  end
end
