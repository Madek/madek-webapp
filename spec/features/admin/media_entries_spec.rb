require "rails_helper"
require "spec_helper_feature_shared"

feature "Admin Media Entries" do
  background { sign_in_as "adam" }

  scenario "Listing media sets" do
    visit "/app_admin"

    dropdown = find("a.dropdown-toggle", text: "Media Resources").find(:xpath, '..').find('ul.dropdown-menu')
    expect(dropdown).to have_css("a", text: "Media Entries")

    within dropdown do
      click_link "Media Entries"
    end
    expect(page).to have_css("h1", text: "Media Entries")
  end

  scenario "Filtering by id" do
    visit "/app_admin/media_entries"

    expect(find_field("filter[search_term]")[:value]).to be_nil
    fill_in "filter[search_term]", with: "cb655264-6fa5-4a7e-bfbe-8f1404ee6323"
    click_button "Apply"
    expect_results_containing("cb655264-6fa5-4a7e-bfbe-8f1404ee6323")
    expect(find_field("filter[search_term]")[:value]).to eq "cb655264-6fa5-4a7e-bfbe-8f1404ee6323"
  end

  scenario "Filtering by custom url" do
    visit "/app_admin/media_entries"

    custom_url = FactoryGirl.create :custom_url
    fill_in "filter[search_term]", with: custom_url.id
    click_button "Apply"
    expect_results_containing(custom_url.media_resource.title)
    expect(find_field("filter[search_term]")[:value]).to eq custom_url.id
  end

  scenario "Filtering by title" do
    visit "/app_admin/media_entries"

    fill_in "filter[search_term]", with: "in my head"
    click_button "Apply"
    expect_results_containing("Shit in my Head")
  end

  def expect_results_containing(text)
    expect(all("table tbody tr", text: text).count).to eq(all("table tbody tr").count)
  end
end
