require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Page: My Dashboard (only logged in user)' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
  end

  pending 'integration test'

  it 'is rendered', browser: false do
    visit '/my/'
    expect(page.status_code).to eq 200
  end

  describe 'Dashboard Sections' do
    [
      :content_media_entries,
      :content_collections,
      :latest_imports,
      :favorite_media_entries,
      :favorite_collections,
      :entrusted_media_entries,
      :entrusted_collections,
      :groups
    ].each do |section|
      it "nested page '#{section.to_s.humanize}' is rendered", browser: false do
        visit "/my/#{section}"
        expect(page.status_code).to eq 200
      end
    end

    it 'non-existing sections give 404 error', browser: false do
      visit '/my/does_not_exist'
      expect(page.status_code).to eq 404
    end

  end
end
