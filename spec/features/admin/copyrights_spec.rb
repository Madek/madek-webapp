require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Copyrights" do
  background do
    sign_in_as "adam"
    visit "/app_admin/copyrights"
  end

  scenario "Editing a copyright" do
    first("a", text: "Details").click
    click_link "Edit"
    fill_in "copyright[label]", with: "AWESOME COPYRIGHT"
    click_button "Save"

    expect(page).to have_css(".alert-success")
    expect(page).to have_content("AWESOME COPYRIGHT")
  end

  scenario "Creating a new copyright" do
    click_link "New copyright"
    fill_in "copyright[label]", with: "NEW COPYRIGHT"
    click_button "Create"

    expect(page).to have_css(".alert-success")
    expect(page).to have_content("NEW COPYRIGHT")
  end
end
