require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Running Madek under a Custom Root-URL' do

  it 'works' do

    unless Rails.application.config.relative_url_root.present?
      raise 'SET the RAILS_RELATIVE_URL_ROOT to e.g. "/my-madek-test" ' \
        'to run this test'
    end

    visit Rails.application.config.relative_url_root

    expect(page).to have_content /Madek/

  end

end
