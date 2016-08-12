require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resilience' do
  it 'pages never return 500 for empty DB', browser: false do
    truncate_tables

    [explore_path,
     explore_catalog_path,
     explore_featured_set_path,
     explore_keywords_path,
     search_path,
     my_dashboard_path]
    .each do |path|
      visit path
      expect(page.status_code).to be < 500
    end

    visit root_path
    expect(page.status_code).to be == 200
  end
end
