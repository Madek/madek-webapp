require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: FilterSet' do

  describe 'Action: index' do

    it 'is rendered for public' do
      visit filter_sets_path
      expect(page.status_code).to eq 200
    end

    it 'is rendered for a logged in user' do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login
      visit filter_sets_path
      expect(page.status_code).to eq 200
    end

  end

end
