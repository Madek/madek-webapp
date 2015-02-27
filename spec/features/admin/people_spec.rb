require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin People' do
  background do
    @admin_user = create :admin_user, password: 'password'
    sign_in_as @admin_user.login
  end

  scenario 'Filtering persons by search term' do
    visit '/admin/people'
    fill_in 'search_term', with: 'nor'
    click_button 'Apply'
    all('table tbody tr').each do |tr|
      expect(tr).to have_content 'nor'
    end
    expect(find_field('search_term')[:value]).to eq 'nor'
  end

  scenario 'Filtering admin persons' do
    visit '/admin/people'
    check 'with_user'
    click_button 'Apply'

    within 'table tbody' do
      expect(page).to have_content @admin_user.person
      expect(page).to have_content @admin_user.login
    end
  end

  scenario 'Creating a new person' do
    visit '/admin/people'
    click_link 'Create person'
    expect(current_path).to eq new_admin_person_path

    fill_in 'person[first_name]', with: 'Fritz'
    fill_in 'person[last_name]', with: 'Fischer'
    click_button 'Save'

    expect(page).to have_content 'Fritz Fischer'
  end

  scenario 'Deleting a person', browser: :firefox do
    person = create :person

    visit admin_person_path(person)
    accept_confirm do
      click_link 'Delete'
    end

    expect(current_path).to eq admin_people_path
    expect { person.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario 'Editing a person' do
    person = create :person

    visit admin_person_path(person)
    click_link 'Edit'
    fill_in 'person[first_name]', with: 'Fritz'
    fill_in 'person[last_name]', with: 'Fischer'
    click_button 'Save'

    expect(current_path).to eq admin_person_path(person)
    person.reload
    expect(person.first_name).to eq 'Fritz'
    expect(person.last_name).to eq 'Fischer'
  end
end
