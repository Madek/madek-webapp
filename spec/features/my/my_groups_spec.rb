require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'Resource: Group; in User Dashboard ("My Groups")' do

  describe 'Action: show' do
    scenario 'Showing a group, has correct name' do
      prepare_data
      login
      visit_groups
      click_group_name
      check_group_path

      within '.ui-body-title' do
        expect(page).to have_content @group.name
      end
    end
  end

  describe 'Action: create' do
    scenario 'Creating a new group by name' do
      prepare_data
      login
      visit_groups
      click_new_group
      check_new_group_path

      fill_in_and_submit_new_group 'NEW_GROUP'

      within '.ui-workgroups' do
        expect(page).to have_content 'NEW_GROUP'
      end
    end

    scenario 'Creating a group with existing name fails with error message' do
      prepare_data
      login

      create :group, name: 'NEW_GROUP'

      visit_groups
      click_new_group
      check_new_group_path

      fill_in_and_submit_new_group 'NEW_GROUP'

      expect(page).to \
        have_content('Überprüfung fehlgeschlagen: Name ist bereits vergeben')
    end

  end

  describe 'Action: update' do
    scenario 'Setting a new name' do
      prepare_data
      login
      visit_groups

      click_edit_button

      set_name_in_form('NEW NAME')
      submit_form

      within '.ui-workgroups' do
        expect(page).not_to have_content @group.name
        expect(page).to have_content 'NEW NAME'
      end
    end

    scenario 'Adding a member' do
      prepare_data
      login
      visit my_groups_path
      click_edit_button

      add_user_in_form(@new_member)
      submit_form

      check_groups_path

      click_edit_button

      within '.ui-rights-group' do
        expect(page).to have_content member_name
      end
    end

    scenario 'Removing a member' do
      prepare_data
      login

      @group.users << @new_member

      visit_groups

      click_edit_button

      within '.ui-rights-group' do
        expect(page).to have_content member_name
      end

      remove_user_in_form(@new_member)
      submit_form

      check_groups_path

      click_edit_button

      within '.ui-rights-group' do
        expect(page).not_to have_content member_name
      end
    end

  end

  describe 'Action: delete' do
    scenario 'Deleting a group, with confirmation' do
      prepare_data
      login

      visit_groups

      within "[data-id='#{@group.id}'] .ui-workgroup-actions" do
        find('button[data-confirm]').click
      end

      check_groups_path

      expect(page).not_to have_content @group.name
    end

    pending 'Deleting a group fails if user is not last remaining member'
  end
end

private

def member_name
  person_name(@new_member)
end

def person_name(user)
  user.person.first_name + ' ' + user.person.last_name
end

def prepare_data
  prepare_user
  @new_member = create(:user)
  @group = create(:group)
  @group.users << @user
end

def member_field_name
  'group[user][login][]'
end

def check_group_path
  expect(current_path).to eq my_group_path(@group)
end

def check_groups_path
  expect(current_path).to eq my_groups_path
end

def check_new_group_path
  expect(current_path).to eq new_my_group_path
end

def visit_groups
  visit my_groups_path
end

def click_group_name
  within "[data-id='#{@group.id}']" do
    click_link @group.name
  end
end

def click_new_group
  click_on 'Neue Arbeitsgruppe'
end

def click_edit_button
  within "[data-id='#{@group.id}']" do
    click_link I18n.t(:group_edit_btn)
  end
end

def fill_in_and_submit_new_group(group_name)
  fill_in 'Name', with: group_name
  submit_form
end

def set_name_in_form(name)
  find('form')
    .find('.ui-form-group', text: 'Name')
    .find('input.form-item')
    .set(name)
end

def add_user_in_form(user)
  autocomplete_and_choose_first(find('.ui-add-subject'), user.login)
end

def remove_user_in_form(user)
  find('tr', text: person_name(user)).find('.ui-rights-remove').click
end
