require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin Vocabularies' do
  let(:admin) { create :admin_user, password: 'password' }
  let(:vocabulary) { create :vocabulary }
  background { sign_in_as admin.login }

  scenario 'Editing a vocabulary' do
    visit admin_vocabularies_path

    filter(vocabulary.id)

    within "[data-id='#{vocabulary.id}']" do
      click_link 'Edit'
    end

    expect(current_path).to eq edit_admin_vocabulary_path(vocabulary)
    expect(page).to have_checked_field 'vocabulary[enabled_for_public_view]'
    expect(page).to have_checked_field 'vocabulary[enabled_for_public_use]'

    fill_in 'vocabulary[label]', with: 'new label'
    fill_in 'vocabulary[description]', with: 'new description'
    uncheck 'vocabulary[enabled_for_public_view]'
    uncheck 'vocabulary[enabled_for_public_use]'

    click_button 'Save'

    expect(current_path).to eq admin_vocabulary_path(vocabulary)
    expect(page).to have_content 'Label new label'
    expect(page).to have_content 'Description new description'
    expect(page).to have_content 'Enabled for public view false'
    expect(page).to have_content 'Enabled for public use false'
  end

  def filter(search_term)
    fill_in 'search_term', with: search_term
    click_button 'Apply'
  end
end
