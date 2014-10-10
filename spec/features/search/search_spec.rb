require 'rails_helper'
require 'spec_helper_feature_shared'

require Rails.root.join "spec","features","search","shared.rb"
include Features::Search::Shared

feature "Search" do

  background do
    @current_user = sign_in_as "normin"
  end

  scenario "Suggested search terms" do

    visit search_path

    # I see one suggested keyword that is randomly picked from the top <count> keywords of resources that I can see
    count = 25

    top_accessible_keywords = Keyword.with_count_for_accessible_media_resources(@current_user).limit(count)
    found = false
    top_accessible_keywords.each do |keyword|
      found = true if all(".ui-search-input[placeholder*='#{keyword}']").size > 0
    end

    raise "this is not one of the top #{count} accessible keywords" unless found

  end

  scenario "Searching for two words", browser: :headless do

    visit search_path

    fill_in "terms", with: "Ausstellung ZHdK"
    submit_form

    check_equality_of_resources_and_result_counters
    check_number_of_displayed_resources

  end

  scenario "Searching from the secondary window", browser: :headless do

    visit "/search/result?terms=Blah"

    fill_in "terms", with: "Ausstellung ZHdK"
    submit_form id: "main_search"

    check_equality_of_resources_and_result_counters
    check_number_of_displayed_resources

  end

end
