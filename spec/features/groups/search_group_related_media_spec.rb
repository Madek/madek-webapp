require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Search for group related media" do
  
  scenario "Number of related media sets displayed in app_admin is the same as number of found media in the search engine", browser: :headless do
    @current_user = sign_in_as 'adam'
    visit '/app_admin/groups'
    find_input_with_name("filter[search_terms]").set("zhdk")
    click_on_text "Apply"
    within("tr#f7cc8c56-5b32-4f23-9a29-8e5c22f8cafc") do
      @count = find(".sets-count").text
      click_on_text "Media sets"
    end
    #new tab - click_on_text "Betrachter/in:"
    visit media_resources_path(permission_presets: {ids: "f7cc8c56-5b32-4f23-9a29-8e5c22f8cafc", category: {view: true, download: false, manage: false, edit: false}}, type: "sets")
    find("#user-action-button").click
    click_on_text "In Admin-Modus wechseln"
    count = find("#resources_counter").text
    expect(count).to eq @count
  end
 
  scenario "Number of related media entries displayed in app_admin is the same as number of found media entries in the search engine", browser: :headless do
    @current_user = sign_in_as 'adam'
    visit '/app_admin/groups'
    find_input_with_name("filter[search_terms]").set("zhdk")
    click_on_text "Apply"
    within("tr#b9318f35-eb4d-4bc8-9220-64cf211e01ee") do
      @count = find(".entries-count").text
      click_on_text "Media entries"
    end
    #new tab - click_on_text "Betrachter/in & Original:"
    visit media_resources_path(permission_presets: {ids: "b9318f35-eb4d-4bc8-9220-64cf211e01ee", category: {view: true, download: true, manage: false, edit: false}}, type: "media_entries")
    count = find("#resources_counter").text
    expect(count).to eq @count
  end

  require Rails.root.join "spec","features","search","shared.rb"
  include Features::Search::Shared
end
