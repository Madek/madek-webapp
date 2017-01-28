require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

# NOTE: this is only a minimal test, also see superproject integration-tests!

feature 'releases info (standalone/development)' do
  let(:repo_git_hash) do
    `git log -n1 --format='%h'`.chomp.presence or fail 'git repo not found!'
  end

  scenario 'release info link in footer' do
    visit '/'

    info = first('.ui-footer-copy a')
    expect(info.text).to eq "Madek git-#{repo_git_hash}"
    expect(current_path_with_query(info[:href])).to eq release_path
  end

  scenario 'release info page' do
    visit release_path

    expect(page).to have_selector('.ui-body-title', text: I18n.t(:release_info))

    within('.app-body-ui-container') do
      info = first('.title-s')
      expect(info.text).to eq "Lokale Git Version: #{repo_git_hash}"
      expect(info.find('a')[:href]).to include repo_git_hash
    end
  end

end
