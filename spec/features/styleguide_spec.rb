require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Styleguide' do

  scenario 'styleguide is rendered without error' do
    paths = [
      '/',          # index
      '?expand=true' # all-in-one
    ]
    paths.each do |path|
      url = styleguide_path + '?' + path
      puts url
      visit url
    end
  end

  scenario 'screenshots test', browser: :firefox do
    paths = ['/Typography', '/Components', '?expand=true']
    paths.each do |path|
      url = styleguide_path + path
      puts url
      visit url
      puts take_screenshot
    end
  end

end
