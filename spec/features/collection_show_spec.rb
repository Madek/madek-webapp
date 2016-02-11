require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: Collections' do

  describe 'Action: show' do

    background do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login
    end

    # TODO: use factories
    the_collection = '/collections/d316b369-6d20-4eb8-b76a-c83f1a4c2682'

    it 'is rendered' do
      visit the_collection
    end

    it 'shows title and responsible user' do
      visit the_collection
      expect(page).to have_content 'Normin Normalo'
      expect(page).to have_content 'Konzepte'
    end

  end

end
