require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MediaEntry#index' do

  it 'is rendered for public' do
    visit media_entries_path
  end

  it 'is rendered for normin' do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
    visit media_entries_path
  end

end
