require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: Collection' do

  describe 'Action: index' do

    it 'is rendered for public' do
      visit collections_path
    end

    pending 'shared_test_filterbar'

    it 'is rendered for a logged in user' do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login
      visit collections_path
    end

  end

end