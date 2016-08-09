require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Page: Explore' do

  # NOTE: re-enable/fix after explore feature is complete
  describe 'Action: index' do

    it 'is rendered for public' do
      visit explore_path
      expect(page.status_code).to eq 200
    end

    it 'is rendered for a logged in user' do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login
      visit explore_path
    end

    it 'no header login button for root page', browser: :firefox do
      visit root_path
      expect(page).to have_no_css(
        '.ui-header-user',
        text: I18n.t(:user_menu_login_btn))
    end

    it 'header login button for explore page', browser: :firefox do
      visit explore_path
      find('.ui-header-user', text: I18n.t(:user_menu_login_btn))
    end

    pending 'shows simple lists of Entries, Collections and FilterSets' \
      'with links to their indexes'

  end

  describe 'Explore content on login page' do

    it 'contains latest entries sorted by created_at DESC' do
      visit root_path
      expect(page.status_code).to eq 200
      within '.ui-resources-holder', text: I18n.t(:home_page_new_contents) do
        expect(
          all("a[type='media-entry']").map { |el| el['href'].split('/').last }
        ).to be == \
          MediaEntry
          .viewable_by_public
          .reorder(created_at: :desc)
          .limit(12)
          .map(&:id)
      end
    end

  end

end
