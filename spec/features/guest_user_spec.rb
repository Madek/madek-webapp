require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Guest/Not logged in user" do
  scenario "Erkunden", browser: :headless do
    visit root_path
    click_on_text "Erkunden"
    
    assert_exact_url_path "/explore"
    expect(page).to have_content "Erkunden"
  end

  scenario "Search page", browser: :headless do
    visit root_path
    click_on_text "Suche"

    assert_exact_url_path "/search"
    expect(page).to have_content "Suche"
    find("#terms").set("Landschaft")
    find("[type='submit']").click

    assert_exact_url_path "/search/result"
    wait_for_ajax
    expect(page).to have_content "Suchresultat"
    expect(page).to have_selector "li[data-media-type='image']"
  end
  
  scenario "All resources I do see have public view permission", browser: :headless do
    visit media_resources_path
    wait_for_ajax
    expect(page).to have_selector "li.ui-resource"
    ids = all("li.ui-resource").map{|el| el['data-id']}
    view_permissions = MediaResource.where(id: ids).map(&:view)
    expect(view_permissions.size).to be > 0
    expect(view_permissions.all?{|p| p == true} ).to  be_truthy
  end
end
