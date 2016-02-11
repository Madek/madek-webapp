require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Page: My Dashboard (only logged in user)' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
  end

  pending 'integration test'

  it 'is rendered' do
    visit '/my/'
  end

  describe 'Dashboard Sections' do
    [
      :content,
      :latest_imports,
      :favorites,
      :entrusted_content,
      :groups
    ].each do |section|
      it "nested page '#{section.to_s.humanize}' is rendered" do
        visit "/my/#{section}"
      end
    end

  end

end
