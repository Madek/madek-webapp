require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MediaEntry' do
  background do
    @user = FactoryBot.create(:user, password: 'password')
    sign_in_as @user.login
  end

  describe 'Action: delete' do

    scenario 'via delete button on detail view (with confirmation)' do

      visit media_entry_path \
        create :media_entry_with_image_media_file,
               creator: @user, responsible_user: @user

      # main actions has a delete button with a confirmation:
      dropdown = find('.ui-body-title-actions').find('.ui-dropdown')
      dropdown.click
      dropdown.find('.icon-trash').click

      within '.modal' do
        find('button', text: I18n.t(:resource_ask_delete_ok)).click
      end

      # redirects to user dashboard:
      expect(current_path).to eq my_dashboard_path
    end

  end
end
