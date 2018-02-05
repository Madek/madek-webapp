require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Errors' do
  let(:user) { create(:user) }

  scenario '500' do
    visit error_500_path
    expect(page).to have_content I18n.t(:error_500_title)
    expect(page).to have_content I18n.t(:error_500_message)
    expect(page).to have_content 'RuntimeError: error 500'
  end

  scenario '401' do
    visit my_dashboard_path
    expect(page).to have_content I18n.t(:error_401_title)
  end

  scenario '403' do
    media_entry = FactoryGirl.create(:media_entry,
                                     is_published: true,
                                     get_metadata_and_previews: false)
    sign_in_as(user)
    visit media_entry_path(media_entry)
    expect(page).to have_content I18n.t(:error_403_title)
    expect(page).to have_content I18n.t(:error_403_message)
  end
end
