require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './shared/basic_data_helper_spec'
include BasicDataHelper

feature 'releases info' do

  scenario 'release info link', browser: :firefox do

    release_info = read_release_info

    visit '/'

    find('.ui-footer-copy a', text: name(release_info)).click

    expect(page).to have_selector(
      '.ui-body-title', text: I18n.t(:release_info))

    within('.app-body-ui-container') do
      expect(page).to have_selector('*', text: version(release_info))
      expect(page).to have_selector('*', text: name(release_info))
    end
  end

  private

  def read_release_info
    data = File.read('../config/releases.yml')
    YAML.safe_load(data)['releases'][0].symbolize_keys
  end

  def version(release_info)
    'v' +
      release_info[:version_major].to_s +
      '.' + release_info[:version_minor].to_s +
      '.' + release_info[:version_patch].to_s +
      '-' + release_info[:version_pre]
  end

  def name(release_info)
    release_info[:name]
  end
end
