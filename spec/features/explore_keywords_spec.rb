require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Page: Explore Keywords' do

  describe 'Action: index' do

    it 'is rendered for public', browser: false do
      visit explore_keywords_path
      expect(page.status_code).to eq 200
    end

    it 'is rendered for a logged in user' do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login
      visit explore_keywords_path
    end

  end

end
