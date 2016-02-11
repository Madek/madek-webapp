require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Page: Explore' do

  describe 'Action: index' do

    it 'is rendered for public' do
      visit explore_path
    end

    it 'is rendered for a logged in user' do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login
      visit explore_path
    end

    pending 'shows simple lists of Entries, Collections and FilterSets' \
      'with links to their indexes'

  end

end
