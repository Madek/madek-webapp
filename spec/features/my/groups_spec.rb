require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'My Groups' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
  end
  let(:group_to_work_with) { @user.groups.last }

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

  scenario 'Editing a group' do
    visit my_groups_path

    within "[data-id='#{group_to_work_with.id}']" do
      click_link 'Edit'
    end

    fill_in 'Name', with: 'NEW NAME'
    submit_form

    within '.ui-workgroups' do
      expect(page).not_to have_content group_to_work_with.name
      expect(page).to have_content 'NEW NAME'
    end
  end

  scenario 'Deleting a group' do
    visit my_groups_path

    within "[data-id='#{group_to_work_with.id}'] .ui-workgroup-actions" do
      find('button[data-confirm]').click
    end

    expect(current_path).to eq my_groups_path

    within '.ui-workgroups' do
      expect(page).not_to have_content group_to_work_with.name
    end
  end

  scenario 'Showing a group' do
    visit my_groups_path

    within "[data-id='#{group_to_work_with.id}']" do
      click_link group_to_work_with.name
    end

    expect(current_path).to eq my_group_path(group_to_work_with)

    within '.ui-body-title' do
      expect(page).to have_content group_to_work_with.name
    end
  end
end
