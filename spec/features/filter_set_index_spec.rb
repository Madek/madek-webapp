require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'FilterSet#index' do

  it 'is rendered for public' do
    visit filter_sets_path
  end

  it 'is rendered for normin' do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
    visit filter_sets_path
  end

end
