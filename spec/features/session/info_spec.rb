require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'


feature 'Session' do

  describe 'session info' do
    given(:user) { create(:user, password: 'password123') }

    scenario 'the user_session contains http_user_agent and remote_addr info' do 
      visit "/"
      fill_in 'login', with: user.login
      fill_in 'password', with: 'password123'
      click_button I18n.t(:login_box_login_btn)

      user_session = UserSession.find_by!(user_id: user.id)
      expect(user_session.meta_data).to be
      expect(user_session.meta_data["http_user_agent"]).to be
      expect(user_session.meta_data["http_user_agent"]).to match /Mozilla/
      expect(user_session.meta_data["remote_addr"]).to be
    end
  end
end



