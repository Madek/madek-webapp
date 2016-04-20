require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative 'shared/favorite_helper_spec'
include FavoriteHelper

feature 'Resource: Collections' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login

    @collection_id = 'd316b369-6d20-4eb8-b76a-c83f1a4c2682'
    @collection = Collection.find @collection_id
    visit collection_path(@collection)
  end

  describe 'Action: show' do
    it 'is rendered' do
      expect(page.status_code).to eq 200
    end

    it 'shows title and responsible user' do
      expect(page).to have_content 'Normin Normalo'
      expect(page).to have_content 'Konzepte'
    end

    it 'Favorite-Button not visible in Toolbar when not logged in' do
      favorite_check_logged_out(@user, @collection)
    end

  end

  describe 'Action: favor (when logged in)' do

    it 'works via Toolbar-Button on "show" View' do
      favorite_check_logged_in(@user, @collection)
    end

  end
end
