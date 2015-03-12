require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'My Dashboard' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
  end

  # TODO: dashboard integration test

  scenario 'main dashboard is rendered' do
    visit '/my/'
  end

  [
    :content,
    :latest_imports,
    :favorites,
    :entrusted_content,
    :groups
  ].each do |section|
    scenario "dashboard section #{section} is rendered" do
      visit "/my/#{section}"
    end
  end

end
