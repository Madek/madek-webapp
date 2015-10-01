require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin Users' do
  background do
    @admin_user = create :admin_user, password: 'password'
    sign_in_as @admin_user.login
  end

  scenario 'Filtering users by search term' do
    visit '/admin/users'
    fill_in 'search_term', with: 'nor'
    click_button 'Apply'
    all('table tbody tr').each do |tr|
      expect(tr).to have_content 'nor'
    end
    expect(find_field('search_term')[:value]).to eq 'nor'
  end

  scenario 'Filtering admin users' do
    visit '/admin/users'
    check 'admins_only'
    click_button 'Apply'

    within 'table tbody' do
      expect(page).to have_content @admin_user.login
      expect(page).to have_content @admin_user.email
    end
  end

  scenario 'Sorting users by login (default behavior)' do
    visit '/admin/users'

    expect(find_field('sort_by')[:value]).to eq('login')

    logins = all('table tbody tr').map do |tr|
      tr.find('td:first').text
    end

    expect(logins).to eq logins.sort
  end

  scenario 'Sorting users by email' do
    visit '/admin/users'

    select 'Email', from: 'sort_by'
    click_button 'Apply'
    expect(find_field('sort_by')[:value]).to eq('email')

    emails = all('table tbody tr').map do |tr|
      tr.all('td')[1].text
    end

    expect(emails).to eq emails.sort
  end

  scenario 'Sorting users by first name and last name' do
    visit '/admin/users'

    select 'First/last name', from: 'sort_by'
    click_button 'Apply'
    expect(find_field('sort_by')[:value]).to eq('first_name_last_name')

    names = all('table tbody tr').map do |tr|
      tr.all('td')[2].text
    end

    expect(names).to eq names.sort
  end

  scenario 'Creating a new user with person' do
    visit '/admin/users'
    click_link 'Create user with person'
    expect(current_path).to eq new_with_person_admin_users_path

    fill_in 'user[person_attributes][first_name]', with: 'Fritz'
    fill_in 'user[person_attributes][last_name]', with: 'Fischer'
    fill_in 'user[login]', with: 'fritzli'
    fill_in 'user[email]', with: 'fritzli@zhdk.ch'
    fill_in 'user[password]', with: 'password'
    click_button 'Save'

    expect(page).to have_content 'Fritz Fischer'
    expect(page).to have_content 'fritzli'
    expect(page).to have_content 'fritzli@zhdk.ch'
    expect(User.find_by(login: 'fritzli')).to be
    expect(Person.find_by(first_name: 'Fritz', last_name: 'Fischer')).to be
  end

  scenario 'Creating a new user for an existing person' do
    person = create :person

    visit '/admin/users'
    click_link 'Create user for existing person'
    fill_in 'user[login]', with: 'fritzli'
    fill_in 'user[email]', with: 'fritzli@zhdk.ch'
    fill_in 'user[password]', with: 'password'
    fill_in 'user[person_id]', with: person.id
    click_button 'Save'

    expect { User.find_by!(login: 'fritzli') }.not_to raise_error
  end

  scenario 'Deleting a user', browser: :firefox do
    user = create :user

    visit admin_user_path(user)
    accept_confirm do
      click_link 'Delete user'
    end

    expect(current_path).to eq admin_users_path
    expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario 'Editing a user' do
    user = create :user

    visit admin_user_path(user)
    click_link 'Edit'
    fill_in 'user[login]', with: 'fritzli'
    fill_in 'user[email]', with: 'fritzli@zhdk.ch'
    click_button 'Save'

    expect(current_path).to eq admin_user_path(user)
    user.reload
    expect(user.login).to eq 'fritzli'
    expect(user.email).to eq 'fritzli@zhdk.ch'
  end

  scenario 'Adding an user to admins' do
    user = create :user

    visit '/admin/users'
    check 'admins_only'
    click_button 'Apply'
    expect(page).not_to have_content user.email

    visit admin_user_path(user)
    click_link 'Grant admin role'
    expect(current_path).to eq admin_user_path(user)
    expect(find('table tr', text: 'Admin?')).to have_content 'Yes'

    visit '/admin/users'
    check 'admins_only'
    click_button 'Apply'
    expect(page).to have_content user.email
  end

  scenario 'Removing an user from admins' do
    user = create :admin_user

    visit '/admin/users'
    check 'admins_only'
    click_button 'Apply'
    expect(page).to have_content user.email

    visit admin_user_path(user)
    click_link 'Remove admin role'
    expect(current_path).to eq admin_user_path(user)
    expect(find('table tr', text: 'Admin?')).to have_content 'No'

    visit '/admin/users'
    check 'admins_only'
    click_button 'Apply'
    expect(page).not_to have_content user.email
  end

  scenario 'Switching to another admin user' do
    user = create :admin_user

    visit '/admin/users'
    fill_in 'search_term', with: user.email
    click_button 'Apply'
    click_link 'Switch to...'
    visit root_path
    expect(page).to have_content I18n.t(:user_menu_logout_btn)
    visit '/admin'
    expect(current_path).to eq admin_root_path
    expect(page).not_to have_content 'Forbidden'
  end

  scenario 'Switching to an ordinary user', browser: :firefox do
    user = create :user

    visit '/admin/users'
    fill_in 'search_term', with: user.email
    click_button 'Apply'
    click_link 'Switch to...'
    visit root_path
    expect(page).to have_content I18n.t(:user_menu_logout_btn)
    visit '/admin'
    expect(current_path).to eq admin_root_path
    expect(page).to have_content 'Admin access denied'
  end
end
