require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Feature: Session' do
describe 'Expiration of Session after configured timeout' do

  describe 'when application has a session timeout 10 seconds' do

    background do
      unless (Madek::Constants::MADEK_SESSION_VALIDITY_DURATION == 10.seconds)
        raise 'SET the MADEK_SESSION_VALIDITY_DURATION to "10 seconds" ' \
          'to run this test'
      end
      user = create(:user)
      sign_in_as user.login, user.password
    end

    specify 'the user is logged out after 12 seconds' do
      visit '/my'
      expect(page).to have_content I18n.t(:sitemap_my_groups)
      expect(page).not_to have_content 'Error 401'
      expect(sleep 12).to be >= 10
      visit current_path
      expect(page).not_to have_content I18n.t(:sitemap_my_groups)
      expect(page).to have_content 'Error 401'
    end

  end

end
end
