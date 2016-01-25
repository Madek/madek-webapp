require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

describe 'Session with 10 expiration' do
  it 'the session validity duration is set to 10 secs' do
    expect(Madek::Constants::MADEK_SESSION_VALIDITY_DURATION).to be == 10.seconds
  end

  describe 'sign-in' do
    let(:user) { create(:user) }
    before { sign_in_as user.login, user.password }

    it 'the session has expired 12 secs after sign-in', browser: :firefox do
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
